import Photos

extension MediaPickerController: PhotoEditorDelegate {
  public func doneEditing(image: UIImage, customFileName: String, selfCtrl: PhotoEditorController, editedSomething: Bool) {
    guard editedSomething else {
      selfCtrl.dismiss(animated: true, completion: nil)
      return
    }
    
    var localId: String?
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      localId = request.placeholderForCreatedAsset?.localIdentifier
    }) { (success, error) in
      DispatchQueue.main.async {
        if let localId = localId {
          let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
          let newAsset = result.object(at: 0)
          
          //self.cart.remove(guidToRemove: selfCtrl.originalImageGuid)
          self.cart.add(Image(asset: newAsset, guid: selfCtrl.originalImageGuid, newlyTaken: false, customFileName: customFileName, dateAdded: Date()))
          selfCtrl.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
  public func canceledEditing() {
    
  }
}

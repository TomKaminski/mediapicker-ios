import Photos

extension MediaPickerController: PhotoEditorDelegate {
  public func doneEditing(image: UIImage, customFileName: String, selfCtrl: PhotoEditorController, editedSomething: Bool, doneWithMedia: Bool) {
    guard editedSomething else {
      if var item = self.cart.getItem(by: selfCtrl.originalImageGuid) {
        item.customFileName = customFileName
        self.cart.add(item)
      }
      selfCtrl.dismiss(animated: !doneWithMedia, completion: {
        if doneWithMedia {
          self.delegate?.mediaPicker(self, didSelectMedia: self.cart.items.values.compactMap { $0 })
        }
      })
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
          selfCtrl.dismiss(animated: !doneWithMedia, completion: {
            if doneWithMedia {
              self.delegate?.mediaPicker(self, didSelectMedia: self.cart.items.values.compactMap { $0 })
            }
          })
        }
      }
    }
  }
  
  public func canceledEditing() {
    
  }
}

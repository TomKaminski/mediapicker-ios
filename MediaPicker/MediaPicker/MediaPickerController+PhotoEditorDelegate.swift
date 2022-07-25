import Photos
import UIKit

extension MediaPickerController: PhotoEditorDelegate {
  public func doneEditing(image: UIImage, customFileName: String, selfCtrl: PhotoEditorController, editedSomething: Bool) {
    guard editedSomething, let cgImage = image.cgImage else {
      if var item = cart.getItem(by: selfCtrl.originalImageGuid) {
        item.customFileName = customFileName
        cart.add(item)
      }
      selfCtrl.dismiss(animated: true, completion: nil)
      return
    }
    
    let fixedImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
    let metadata = self.getMetaData(image: fixedImage)
    var localId: String?
    
    PHPhotoLibrary.shared().performChanges({
      var request: PHAssetChangeRequest
      
      if let metadata = metadata, !metadata.isEmpty, let imageData = fixedImage.jpegData(compressionQuality: 1), let newImageData = self.mergeImageData(imageData: imageData, with: metadata) {
        request = PHAssetCreationRequest.forAsset()
        (request as! PHAssetCreationRequest).addResource(with: .photo, data: newImageData as Data, options: nil)
      }
      else {
        request = PHAssetChangeRequest.creationRequestForAsset(from: fixedImage)
      }
      localId = request.placeholderForCreatedAsset?.localIdentifier
    }) { (success, error) in
      DispatchQueue.main.async {
        if let localId = localId {
          let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
          let newAsset = result.object(at: 0)
          
          self.cart.remove(guidToRemove: selfCtrl.originalImageGuid)
          self.cart.add(Image(asset: newAsset, guid: selfCtrl.originalImageGuid, newlyTaken: false, customFileName: customFileName, dateAdded: Date()))
          selfCtrl.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
  public func canceledEditing() {
    
  }
  
  internal func getMetaData(image: UIImage) -> [String: Any]? {
    if let imageData = image.jpegData(compressionQuality: 1), let sourceRef = CGImageSourceCreateWithData(imageData as CFData, nil), let metadata = CGImageSourceCopyPropertiesAtIndex(sourceRef, 0, nil) as? [String: Any] {
      return metadata
    }
    return nil
  }
  
  internal func mergeImageData(imageData: Data, with metadata: [String: Any]) -> Data? {
    if let source: CGImageSource = CGImageSourceCreateWithData(imageData as NSData, nil), let UTI: CFString = CGImageSourceGetType(source) {
      let newImageData =  NSMutableData()
      if let cgImage = UIImage(data: imageData)?.cgImage, let imageDestination: CGImageDestination = CGImageDestinationCreateWithData((newImageData as CFMutableData), UTI, 1, nil) {
        CGImageDestinationAddImage(imageDestination, cgImage, metadata as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return newImageData as Data
      }
    }
    
    return nil
  }
}

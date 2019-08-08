import UIKit
import Photos

extension UIImageView {
  
  func loadImage(_ asset: PHAsset) {
    guard frame.size != CGSize.zero else {
      image = MediaPickerBundle.image("gallery_placeholder")
      return
    }
    
    if tag == 0 {
      image = MediaPickerBundle.image("gallery_placeholder")
    } else {
      PHImageManager.default().cancelImageRequest(PHImageRequestID(tag))
    }
    
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    
    let id = PHImageManager.default().requestImage(
      for: asset,
      targetSize: frame.size,
      contentMode: .aspectFill,
      options: options) { [weak self] image, _ in
        self?.image = image
    }
    
    tag = Int(id)
  }
}

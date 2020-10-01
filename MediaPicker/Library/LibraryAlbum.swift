import UIKit
import Photos

class Album {
  
  let collection: PHAssetCollection
  var images: [Image] = []
  var videos: [Video] = []

  // MARK: - Initialization
  
  init(collection: PHAssetCollection) {
    self.collection = collection
  }
  
  func reload() {
    images = []
    videos = []
    
    let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
    itemsFetchResult.enumerateObjects({ (asset, count, stop) in
      if asset.mediaType == .image && !asset.mediaSubtypes.contains(.photoLive) {
        self.images.append(Image(asset: asset, guid: UUID().uuidString, newlyTaken: false, customFileName: FileNameComposer.getImageFileName(), dateAdded: Date()))
      } else if asset.mediaType == .video && MediaPickerConfig.instance.videoRecording.allow {
        self.videos.append(Video(asset: asset, guid: UUID().uuidString, customFileName: FileNameComposer.getImageFileName(), newlyTaken: false, dateAdded: Date()))
      }
    })
  }
}

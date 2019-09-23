import UIKit
import Photos

public class Video: Equatable, CartItemProtocol {
  public var customFileName: String?
  
  public var guid: String
  
  func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
  }
  
  public var cartView: CartCollectionItemView {
    return CartCollectionItemView(type: .Video, guid: guid, imageCompletion: { (imageView) in
      self.fetchThumbnail(completion: { (image) in
        imageView.image = image
      })
    }, bottomTextFunc: { label in
      self.fetchDuration({ (seconds) in
        let result = self.secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let seconds = result.2 < 10 ? "0\(result.2)" : "\(result.2)"
        label.text = "\(result.1):\(seconds)"
      })
    })
  }
  
  public var type: CartItemType {
    return .Video
  }

  public var asset: PHAsset
  
  var durationRequestID: Int = 0
  var duration: Double = 0
  
  // MARK: - Initialization
  
  init(asset: PHAsset, guid: String) {
    self.asset = asset
    self.guid = guid
  }
  
  /// Fetch video duration asynchronously
  ///
  /// - Parameter completion: Called when finish
  func fetchDuration(_ completion: @escaping (Double) -> Void) {
    guard duration == 0
      else {
        DispatchQueue.main.async {
          completion(self.duration)
        }
        return
    }
    
    if durationRequestID != 0 {
      PHImageManager.default().cancelImageRequest(PHImageRequestID(durationRequestID))
    }
    
    let id = PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) {
      asset, mix, _ in
      
      self.duration = asset?.duration.seconds ?? 0
      DispatchQueue.main.async {
        completion(self.duration)
      }
    }
    
    durationRequestID = Int(id)
  }
  
  /// Fetch AVPlayerItem asynchronoulys
  ///
  /// - Parameter completion: Called when finish
  public func fetchPlayerItem(_ completion: @escaping (AVPlayerItem?) -> Void) {
    PHImageManager.default().requestPlayerItem(forVideo: asset, options: videoOptions) {
      item, _ in
      
      DispatchQueue.main.async {
        completion(item)
      }
    }
  }
  
  /// Fetch AVAsset asynchronoulys
  ///
  /// - Parameter completion: Called when finish
  public func fetchAVAsset(_ completion: @escaping (AVAsset?) -> Void) {
    PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, _, _ in
      DispatchQueue.main.async {
        completion(avAsset)
      }
    }
  }
  
  /// Fetch thumbnail image for this video asynchronoulys
  ///
  /// - Parameter size: The preferred size
  /// - Parameter completion: Called when finish
  public func fetchThumbnail(size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestImage(
      for: asset,
      targetSize: size,
      contentMode: .aspectFill,
      options: options) { image, _ in
        DispatchQueue.main.async {
          completion(image)
        }
    }
  }
  
  // MARK: - Helper
  
  private var videoOptions: PHVideoRequestOptions {
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true
    
    return options
  }
  
  func getURL(completionHandler : @escaping ((_ responseURL : NSURL?) -> Void)){
    let options: PHVideoRequestOptions = PHVideoRequestOptions()
    options.version = .original
    PHImageManager.default().requestAVAsset(forVideo: self.asset, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
      if let urlAsset = asset as? AVURLAsset {
        let localVideoUrl: NSURL = urlAsset.url as NSURL
        completionHandler(localVideoUrl)
      } else {
        completionHandler(nil)
      }
    })
  }
}

// MARK: - Equatable

public func ==(lhs: Video, rhs: Video) -> Bool {
  return lhs.asset == rhs.asset
}

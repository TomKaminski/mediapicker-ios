import UIKit
import Photos

public class Image: Equatable, CartItemProtocol {
  public var dateAdded: Date
  public var newlyTaken: Bool
  public var guid: String
  public var customFileName: String
  
  public var cartView: CartCollectionItemView {
    return CartCollectionItemView(type: .Image, guid: guid, imageCompletion: { (imageView) in
      self.resolve(completion: { (image) in
        imageView.image = image
      })
    })
  }

  public var type: CartItemType {
    return .Image
  }

  public let asset: PHAsset

  // MARK: - Initialization

  init(asset: PHAsset, guid: String, newlyTaken: Bool, customFileName: String, dateAdded: Date) {
    self.newlyTaken = newlyTaken
    self.asset = asset
    self.guid = guid
    self.customFileName = customFileName
    self.dateAdded = dateAdded
  }
}

// MARK: - UIImage

extension Image {
  public func resolveData(completion: @escaping (Data?) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .highQualityFormat
    
    PHImageManager.default().requestImageData(for: asset, options: options) { (data, _, _, _) in
      completion(data)
    }
  }

  /// Resolve UIImage synchronously
  ///
  /// - Parameter size: The target size
  /// - Returns: The resolved UIImage, otherwise nil
  public func resolve(completion: @escaping (UIImage?) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .highQualityFormat

    let targetSize = CGSize(
      width: asset.pixelWidth,
      height: asset.pixelHeight
    )

    PHImageManager.default().requestImage(
      for: asset,
      targetSize: targetSize,
      contentMode: .default,
      options: options) { (image, _) in
      completion(image)
    }
  }

  /// Resolve an array of Image
  ///
  /// - Parameters:
  ///   - images: The array of Image
  ///   - size: The target size for all images
  ///   - completion: Called when operations completion
  public static func resolve(images: [Image], completion: @escaping ([UIImage?]) -> Void) {
    let dispatchGroup = DispatchGroup()
    var convertedImages = [Int: UIImage]()

    for (index, image) in images.enumerated() {
      dispatchGroup.enter()

      image.resolve(completion: { resolvedImage in
        if let resolvedImage = resolvedImage {
          convertedImages[index] = resolvedImage
        }

        dispatchGroup.leave()
      })
    }

    dispatchGroup.notify(queue: .main, execute: {
      let sortedImages = convertedImages
        .sorted(by: { $0.key < $1.key })
        .map({ $0.value })
      completion(sortedImages)
    })
  }
}

// MARK: - Equatable

public func == (lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}

import UIKit
import AVFoundation

public class Audio: Equatable, CartItemProtocol {

  public var cartView: CartCollectionItemView {
    return CartCollectionItemView(image: MediaPickerBundle.image("gallery_camera_flash_auto")!)
  }

  public var type: CartItemType {
    return .Audio
  }

  public let audioFile: AVAudioFile
  public let fileName: String
  public let newFileName: String?
  public var guid: String

  public var duration: Double = 0

  init(audioFile: AVAudioFile, fileName: String, newFileName: String?, guid: String) {
    self.audioFile = audioFile
    self.fileName = fileName
    self.newFileName = newFileName
    self.guid = guid
  }

  static public func == (lhs: Audio, rhs: Audio) -> Bool {
    return lhs.audioFile == rhs.audioFile
  }

  public func removeSelfFromCart() {

  }

  public func runPreviewOrEdit() {

  }

  func fetchDuration(_ completion: @escaping (Double) -> Void) {
    guard duration == 0 else {
      DispatchQueue.main.async {
        completion(self.duration)
      }
      return
    }

    if let audioPlayer = try? AVAudioPlayer(contentsOf: audioFile.url) {
      self.duration = audioPlayer.duration
      DispatchQueue.main.async {
        completion(self.duration)
      }
    }
  }
}

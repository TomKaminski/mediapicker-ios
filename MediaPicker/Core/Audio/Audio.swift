import UIKit
import AVFoundation

public class Audio: Equatable, CartItemProtocol {
  func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
  }
  
  public var cartView: CartCollectionItemView {
    let tempCartView = CartCollectionItemView(type: .Audio, guid: self.guid, image: MediaPickerBundle.image("musicIcon")!.imageWithInsets(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))!, bottomTextFunc: { label in
      self.fetchDuration({ (seconds) in
        let result = self.secondsToHoursMinutesSeconds(seconds: Int(seconds))
        let seconds = result.2 < 10 ? "0\(result.2)" : "\(result.2)"
        label.text = "\(result.1):\(seconds)"
      })
    })
    tempCartView.backgroundColor = .white
    return tempCartView
  }

  public var type: CartItemType {
    return .Audio
  }

  public let audioFile: AVAudioFile
  public let fileName: String
  public var customFileName: String?
  public var guid: String

  public var duration: Double = 0

  init(audioFile: AVAudioFile, fileName: String, newFileName: String?, guid: String) {
    self.audioFile = audioFile
    self.fileName = fileName
    self.customFileName = newFileName
    self.guid = guid
  }

  static public func == (lhs: Audio, rhs: Audio) -> Bool {
    return lhs.audioFile == rhs.audioFile
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

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
  public var customFileName: String
  public var guid: String
  public var newlyTaken: Bool
  public var dateAdded: Date

  public var duration: Double = 0

  init(audioFile: AVAudioFile, customFileName: String, guid: String, dateAdded: Date) {
    self.audioFile = audioFile
    self.customFileName = customFileName
    self.guid = guid
    self.newlyTaken = true
    self.dateAdded = dateAdded
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

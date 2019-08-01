import UIKit
import AVFoundation

public class Audio: Equatable {
  public let audioFile: AVAudioFile
  public let fileName: String
  public let newFileName: String?
  
  var duration: Double = 0
  
  init(audioFile: AVAudioFile, fileName: String, newFileName: String?) {
    self.audioFile = audioFile
    self.fileName = fileName
    self.newFileName = newFileName
  }
  
  static public func == (lhs: Audio, rhs: Audio) -> Bool {
    return lhs.audioFile == rhs.audioFile
  }
  
  //  func fetchDuration(_ completion: @escaping (Double) -> Void) {
  //    guard duration == 0 else {
  //      DispatchQueue.main.async {
  //        completion(self.duration)
  //      }
  //      return
  //    }
  //
  //    if let audioPlayer = try? AVAudioPlayer(contentsOf: audioFile.url) {
  //      self.duration = audioPlayer.duration
  //      DispatchQueue.main.async {
  //        completion(self.duration)
  //      }
  //    }
  //  }
}

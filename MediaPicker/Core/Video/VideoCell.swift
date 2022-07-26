import UIKit
import Photos

class VideoCell: ImageCell {
  lazy var durationLabel: UILabel = self.makeDurationLabel()
  lazy var bottomOverlay: UIView = self.makeBottomOverlay()

  func configure(_ video: Video) {
    super.configure(video.asset)
    
    video.fetchDuration { duration in
      DispatchQueue.main.async {
        self.durationLabel.text = "\(Utils.format(duration))"
      }
    }
  }
  
  override func setup() {
    super.setup()
    
    [bottomOverlay, durationLabel].forEach {
      self.insertSubview($0, belowSubview: self.highlightOverlay)
    }
        
    bottomOverlay.g_pinDownward()
    bottomOverlay.g_pin(height: 16)
    
    durationLabel.g_pin(on: .right, constant: -4)
    durationLabel.g_pin(on: .bottom, constant: -2)
  }
  
  func makeDurationLabel() -> UILabel {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 9)
    label.textColor = UIColor.white
    label.textAlignment = .right
    
    return label
  }
  
  func makeBottomOverlay() -> UIView {
    let view = UIView()
    view.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    
    return view
  }
  
  private func makeFrameView() -> FrameView {
    let frameView = FrameView(frame: .zero)
    frameView.alpha = 0
    
    return frameView
  }
}

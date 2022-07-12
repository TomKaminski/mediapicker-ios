import UIKit
import Photos

class ImageCell: UICollectionViewCell {
  lazy var imageView: UIImageView = self.makeImageView()
  lazy var highlightOverlay: UIView = self.makeHighlightOverlay()
  lazy var frameView: FrameView = self.makeFrameView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var isHighlighted: Bool {
    didSet {
      highlightOverlay.isHidden = !isHighlighted
    }
  }
    
  func configure(_ asset: PHAsset) {
    imageView.layoutIfNeeded()
    imageView.loadImage(asset)
  }
  
  func configure(_ image: Image) {
    configure(image.asset)
  }
    
  func setup() {
    [imageView, frameView, highlightOverlay].forEach {
      self.contentView.addSubview($0)
    }
    
    imageView.g_pinEdges()
    frameView.g_pinEdges()
    highlightOverlay.g_pinEdges()
  }

  private func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill
    return imageView
  }
  
  private func makeHighlightOverlay() -> UIView {
    let view = UIView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = MediaPickerConfig.instance.colors.primary.withAlphaComponent(0.3)
    view.isHidden = true
    return view
  }
  
  private func makeFrameView() -> FrameView {
    let frameView = FrameView(frame: .zero)
    frameView.alpha = 0
    return frameView
  }
}

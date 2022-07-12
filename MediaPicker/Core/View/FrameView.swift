import UIKit

class FrameView: UIView {
  lazy var gradientLayer: CAGradientLayer = self.makeGradientLayer()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    layer.addSublayer(gradientLayer)
    layer.borderColor = MediaPickerConfig.instance.colors.primary.cgColor
    layer.borderWidth = 2
    clipsToBounds = true
  }
  
  // MARK: - Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    gradientLayer.frame = bounds
  }
  
  private func makeGradientLayer() -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [
      MediaPickerConfig.instance.colors.primary.withAlphaComponent(0.25).cgColor,
      MediaPickerConfig.instance.colors.primary.withAlphaComponent(0.4).cgColor
    ]
    
    return layer
  }
}

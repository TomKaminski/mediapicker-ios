import UIKit

class ShutterButton: UIButton {
  
  lazy var overlayView: UIView = self.makeOverlayView()
  lazy var roundLayer: CAShapeLayer = self.makeRoundLayer()
  
  var recording: Bool = false {
    didSet {
      recordingChanged()
    }
  }
  
  private func recordingChanged() {
    UIView.animate(withDuration: 0.5) {
      self.overlayView.backgroundColor = self.recording ? .red : .white
    }
  }
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Layout
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    overlayView.frame = bounds.insetBy(dx: 4, dy: 4)
    overlayView.layer.cornerRadius = overlayView.frame.size.width / 2
    
    roundLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 6, dy: 6)).cgPath
    layer.cornerRadius = bounds.size.width / 2
  }
  
  // MARK: - Setup
  
  func setup() {
    backgroundColor = UIColor.white
    
    addSubview(overlayView)
    layer.addSublayer(roundLayer)
  }
  
  // MARK: - Controls
  
  func makeOverlayView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.white
    view.isUserInteractionEnabled = false
    
    return view
  }
  
  func makeRoundLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.strokeColor = MediaPickerConfig.instance.colors.black.cgColor
    layer.lineWidth = 5
    layer.fillColor = nil
    
    return layer
  }
}

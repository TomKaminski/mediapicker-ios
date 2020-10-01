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
    if recording {
      
      UIView.animate(withDuration: 0.5) {
        self.overlayView.backgroundColor = .red
        self.roundLayer.strokeColor = UIColor.red.cgColor
        self.backgroundColor = .red
      }
    } else {
      UIView.animate(withDuration: 0.5) {
        self.overlayView.backgroundColor = .white
        self.roundLayer.strokeColor = MediaPickerConfig.instance.camera.shutterButton.numberColor.cgColor
        self.backgroundColor = .white
      }
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
    
    overlayView.frame = bounds.insetBy(dx: 3, dy: 3)
    overlayView.layer.cornerRadius = overlayView.frame.size.width / 2
    
    roundLayer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: 3, dy: 3)).cgPath
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
    layer.strokeColor = MediaPickerConfig.instance.camera.shutterButton.numberColor.cgColor
    layer.lineWidth = 2
    layer.fillColor = nil
    
    return layer
  }
}

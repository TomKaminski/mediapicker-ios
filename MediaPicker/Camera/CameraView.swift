import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint)
  func cameraView(_ cameraView: CameraView, didPinched pinch: UIPinchGestureRecognizer)
}

class CameraView: UIView, UIGestureRecognizerDelegate {
  lazy var rotateOverlayView: UIView = self.makeRotateOverlayView()
  lazy var focusImageView: UIImageView = self.makeFocusImageView()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()
  lazy var pinchGR: UIPinchGestureRecognizer = self.makePinchGR()
  lazy var blurView: UIVisualEffectView = self.makeBlurView()
  lazy var shutterOverlayView: UIView = self.makeShutterOverlayView()
  
  var timer: Timer?
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var delegate: CameraViewDelegate?

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = .black
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    addGestureRecognizer(tapGR)
    addGestureRecognizer(pinchGR)

    rotateOverlayView.addSubview(blurView)
    addSubview(rotateOverlayView)
    
    insertSubview(shutterOverlayView, belowSubview: blurView)
    insertSubview(focusImageView, belowSubview: blurView)

    rotateOverlayView.g_pinEdges()
    blurView.g_pinEdges()
    shutterOverlayView.g_pinEdges()
  }

  func setupPreviewLayer(_ session: AVCaptureSession) {
    let videoLayer = AVCaptureVideoPreviewLayer(session: session)
    videoLayer.autoreverses = true
    videoLayer.videoGravity = .resizeAspectFill
    videoLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)

    if previewLayer != nil  {
      self.layer.replaceSublayer(previewLayer!, with: videoLayer)
    } else {
      self.layer.insertSublayer(videoLayer, at: 0)
    }
    
    previewLayer = videoLayer
  }

  // MARK: - Action

  @objc func viewTapped(_ gr: UITapGestureRecognizer) {
    let point = gr.location(in: self)
    let screenSize = self.bounds.size

    let x = gr.location(in: self).y / screenSize.height
    let y = 1.0 - gr.location(in: self).x / screenSize.width
    let focusPoint = CGPoint(x: x, y: y)

    focusImageView.transform = CGAffineTransform.identity
    timer?.invalidate()
    delegate?.cameraView(self, didTouch: focusPoint)

    focusImageView.center = point

    UIView.animate(withDuration: 0.5, animations: {
      self.focusImageView.alpha = 1
      self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }, completion: { _ in
      self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                        selector: #selector(CameraView.timerFired(_:)), userInfo: nil, repeats: false)
    })
  }
  
  @objc func viewPinched(_ gr: UIPinchGestureRecognizer) {
    delegate?.cameraView(self, didPinched: gr)
  }

  // MARK: - Timer

  @objc func timerFired(_ timer: Timer) {
    UIView.animate(withDuration: 0.3, animations: {
      self.focusImageView.alpha = 0
    }, completion: { _ in
      self.focusImageView.transform = CGAffineTransform.identity
    })
  }

  func makeFocusImageView() -> UIImageView {
    let view = UIImageView()
    view.frame.size = CGSize(width: 110, height: 110)
    view.image = MediaPickerBundle.image("gallery_camera_focus")
    view.backgroundColor = .clear
    view.alpha = 0

    return view
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    gr.delegate = self

    return gr
  }
  
  func makePinchGR() -> UIPinchGestureRecognizer {
    let gr = UIPinchGestureRecognizer(target: self, action: #selector(viewPinched(_:)))
    gr.delegate = self

    return gr
  }

  func makeRotateOverlayView() -> UIView {
    let view = UIView()
    view.alpha = 0

    return view
  }

  func makeBlurView() -> UIVisualEffectView {
    let effect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: effect)

    return blurView
  }

  func makeShutterOverlayView() -> UIView {
    let view = UIView()
    view.alpha = 0
    view.backgroundColor = UIColor.black

    return view
  }
}

import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint)
}

class CameraView: UIView, UIGestureRecognizerDelegate {
  lazy var flashButton: TripleButton = self.makeFlashButton()
  lazy var rotateButton: UIButton = self.makeRotateButton()
  lazy var rotateOverlayView: UIView = self.makeRotateOverlayView()
  lazy var focusImageView: UIImageView = self.makeFocusImageView()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()
  lazy var blurView: UIVisualEffectView = self.makeBlurView()
  lazy var shutterOverlayView: UIView = self.makeShutterOverlayView()

  var timer: Timer?
  var videoRecordingTimer: Timer?
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var delegate: CameraViewDelegate?

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.black
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    addGestureRecognizer(tapGR)

    [flashButton, rotateButton].forEach {
      addSubview($0)
    }

    rotateOverlayView.addSubview(blurView)
    insertSubview(rotateOverlayView, belowSubview: rotateButton)
    insertSubview(shutterOverlayView, belowSubview: blurView)

    rotateButton.g_pin(on: .right)
    rotateButton.g_pin(size: CGSize(width: 44, height: 44))
    flashButton.g_pin(on: .left)
    flashButton.g_pin(size: CGSize(width: 80, height: 44))

    if #available(iOS 11, *) {
      Constraint.on(constraints: [
        rotateButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        flashButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)]
      )
    } else {
      Constraint.on(constraints: [
        rotateButton.topAnchor.constraint(equalTo: topAnchor),
        flashButton.topAnchor.constraint(equalTo: topAnchor)]
      )
    }

    rotateOverlayView.g_pinEdges()
    blurView.g_pinEdges()
    shutterOverlayView.g_pinEdges()
  }

  func setupPreviewLayer(_ session: AVCaptureSession) {
    guard previewLayer == nil else { return }

    let layer = AVCaptureVideoPreviewLayer(session: session)
    layer.autoreverses = true
    layer.videoGravity = .resizeAspectFill

    self.layer.insertSublayer(layer, at: 0)
    layer.frame = CGRect(x: 0, y: 60, width: self.frame.width, height: self.frame.height - 60)
    previewLayer = layer
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    previewLayer?.frame = self.layer.bounds
  }

  // MARK: - Action

  @objc func viewTapped(_ gr: UITapGestureRecognizer) {
    let point = gr.location(in: self)

    focusImageView.transform = CGAffineTransform.identity
    timer?.invalidate()
    delegate?.cameraView(self, didTouch: point)

    focusImageView.center = point

    UIView.animate(withDuration: 0.5, animations: {
      self.focusImageView.alpha = 1
      self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }, completion: { _ in
      self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                        selector: #selector(CameraView.timerFired(_:)), userInfo: nil, repeats: false)
    })
  }

  // MARK: - Timer

  @objc func timerFired(_ timer: Timer) {
    UIView.animate(withDuration: 0.3, animations: {
      self.focusImageView.alpha = 0
    }, completion: { _ in
      self.focusImageView.transform = CGAffineTransform.identity
    })
  }

  // MARK: - Controls

  func makeChangeModeButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle("LandaxApp_Gallery_ChangeMode_Button".g_localize(fallback: "Change mode"), for: .normal)

    return button
  }

  func makeFlashButton() -> TripleButton {
    let states: [TripleButton.GalleryState] = [
      TripleButton.GalleryState(title: "LandaxApp_Gallery_Camera_Flash_Off".g_localize(fallback: "OFF"), image: MediaPickerBundle.image("gallery_camera_flash_off")!),
      TripleButton.GalleryState(title: "LandaxApp_Gallery_Camera_Flash_On".g_localize(fallback: "ON"), image: MediaPickerBundle.image("gallery_camera_flash_on")!),
      TripleButton.GalleryState(title: "LandaxApp_Gallery_Camera_Flash_Auto".g_localize(fallback: "AUTO"), image: MediaPickerBundle.image("gallery_camera_flash_auto")!)
    ]

    let button = TripleButton(states: states)

    return button
  }

  func makeRotateButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(MediaPickerBundle.image("gallery_camera_rotate"), for: UIControl.State())

    return button
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

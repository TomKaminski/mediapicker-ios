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
  lazy var elapsedVideoRecordingTimeLabel: UILabel = self.makeVideoRecordingElapsedTimeLabel()
  
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
  
  func showTimer() {
    let userInfo = ["start": Date().timeIntervalSince1970]
    self.videoRecordingTimer = Timer.scheduledTimer(
      timeInterval: 0.5, target: self, selector: #selector(CameraView.videoRecodringTimerFired(_:)), userInfo: userInfo, repeats: true)
    self.elapsedVideoRecordingTimeLabel.isHidden = false
    self.elapsedVideoRecordingTimeLabel.text = self.videoRecordingLabelPlaceholder()
  }

  func setup() {
    addGestureRecognizer(tapGR)

    [flashButton, rotateButton, elapsedVideoRecordingTimeLabel].forEach {
      addSubview($0)
    }

    rotateOverlayView.addSubview(blurView)
    insertSubview(rotateOverlayView, belowSubview: rotateButton)
    insertSubview(shutterOverlayView, belowSubview: blurView)

    elapsedVideoRecordingTimeLabel.g_pin(on: .centerX)
    elapsedVideoRecordingTimeLabel.g_pin(size: CGSize(width: 100, height: 44))
    rotateButton.g_pin(on: .right)
    rotateButton.g_pin(size: CGSize(width: 44, height: 44))
    flashButton.g_pin(on: .left)
    flashButton.g_pin(size: CGSize(width: 80, height: 44))

    if #available(iOS 11, *) {
      Constraint.on(constraints: [
        rotateButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        flashButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
        elapsedVideoRecordingTimeLabel.topAnchor.constraint(equalTo: elapsedVideoRecordingTimeLabel.topAnchor),
      ])
    } else {
      Constraint.on(constraints: [
        rotateButton.topAnchor.constraint(equalTo: topAnchor),
        flashButton.topAnchor.constraint(equalTo: topAnchor),
        elapsedVideoRecordingTimeLabel.topAnchor.constraint(equalTo: topAnchor),
      ])
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
    button.setImage(MediaPickerBundle.image("cameraIcon"), for: UIControl.State())

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
  
  func makeVideoRecordingElapsedTimeLabel() -> UILabel {
    let label = UILabel()
    label.text = self.videoRecordingLabelPlaceholder()
    label.textAlignment = .center
    label.textColor = .white
    label.isHidden = true
    label.font = UIFont.systemFont(ofSize: 14)
    return label
  }

  func videoRecordingLabelPlaceholder() -> String {
    return "--:--"
  }
  
  @objc func videoRecodringTimerFired(_ timer: Timer) {
    guard let dictionary = timer.userInfo as? [String: Any], let start = dictionary["start"] as? TimeInterval else {
      return
    }
    let now = Date().timeIntervalSince1970
    let minutes = Int(now - start) / 60
    let seconds = Int(now - start) % 60
    self.elapsedVideoRecordingTimeLabel.text = String(format: "%0.2d:%0.2d", minutes, seconds)
  }
}

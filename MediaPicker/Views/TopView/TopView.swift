import UIKit

protocol CameraTabTopViewDelegate: AnyObject {
  func onFlashToggle(selectedIndex: Int)
  func onRotateToggle()
}

protocol LibraryTabTopViewDelegate: AnyObject {
  func onDropdownTap()
}

class TopView: UIView {
  var state: MediaToolbarState = .Camera {
    didSet {
      setupForState()
    }
  }
  
  var activeTab: GalleryTab = .cameraTab {
    didSet {
      setupForActiveTab()
    }
  }
  
  var videoRecordingTimer: Timer?
  
  lazy var timerLabel: UILabel = self.makeTimerLabel()
  lazy var backButton: UIButton = self.makeBackButton()
  lazy var flashButton: FlashButton = self.makeFlashButton()
  lazy var rotateButton: UIButton = self.makeRotateButton()
  lazy var dropdownButton: ArrowButton = self.makeDropdownButton()
  
  weak var cameraDelegate: CameraTabTopViewDelegate?
  weak var libraryDelegate: LibraryTabTopViewDelegate?
  
  required init() {
    super.init(frame: .zero)
    self.backgroundColor = MediaPickerConfig.instance.colors.black.withAlphaComponent(0.2)
    setup()
  }
  
  public func toggleViewsVisibility() {
    rotateButton.isHidden = !rotateButton.isHidden
    flashButton.isHidden = !flashButton.isHidden
    backButton.isHidden = !backButton.isHidden
  }
  
  func setup() {
    insertBackButton()
    setupForActiveTab()
  }
  
  func setupForState() {
    clearSubviews()

    switch state {
    case .Camera:
      setupCameraLayout()
    case .Library:
      setupLibraryLayout()
    case .Audio, .AudioRecording:
      break
    }
  }
  
  func setupForActiveTab() {
    clearSubviews()

    switch activeTab {
    case .libraryTab:
      setupLibraryLayout()
    case .cameraTab:
      setupCameraLayout()
    case .audioTab:
      break
    }
  }
  
  func makeBackButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("addPhotoIcon"), for: UIControl.State())
    button.addTarget(self, action: #selector(onBackButtonTap), for: .touchUpInside)
    return button
  }
  
  func makeFlashButton() -> FlashButton {
    let states = [
      MediaPickerBundle.image("FlashOff")!,
      MediaPickerBundle.image("FlashOn")!,
      MediaPickerBundle.image("gallery_camera_flash_auto")!
    ]

    let button = FlashButton(states: states)
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }

  func makeRotateButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Switch"), for: UIControl.State())

    return button
  }
  
  func makeTimerLabel() -> UILabel {
    let label = UILabel()
    label.alpha = 0
    label.textAlignment = .center
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 16)
    return label
  }
  
  private func makeDropdownButton() -> ArrowButton {
    let button = ArrowButton()
    return button
  }
  
  fileprivate func insertBackButton() {
    addSubview(backButton)
    backButton.g_pin(on: .left, view: self, on: .left, constant: 16)
    backButton.g_pin(on: .bottom, view: self, on: .bottom, constant: -12)
    backButton.g_pin(width: 30)
  }
  
  fileprivate func insertFlash() {
    addSubview(flashButton)
    flashButton.g_pin(on: .right, view: rotateButton, on: .left, constant: -8)
    flashButton.g_pin(on: .bottom, view: self, on: .bottom, constant: -12)
    flashButton.g_pin(width: 30)
    flashButton.addTarget(self, action: #selector(flashButtonTouched(_:)), for: .touchUpInside)
  }
  
  fileprivate func insertRotate() {
    addSubview(rotateButton)
    rotateButton.g_pin(on: .right, view: self, on: .right, constant: -20)
    rotateButton.g_pin(on: .bottom, view: self, on: .bottom, constant: -12)
    rotateButton.g_pin(width: 30)
    rotateButton.addTarget(self, action: #selector(rotateButtonTouched(_:)), for: .touchUpInside)
  }
  
  fileprivate func insertTimerLabel() {
    addSubview(timerLabel)
    timerLabel.g_pin(on: .centerX, view: self, on: .centerX)
    timerLabel.g_pin(on: .bottom, view: self, on: .bottom, constant: -12)
  }
  
  fileprivate func insertDropdownButton() {
    addSubview(dropdownButton)
    dropdownButton.g_pin(on: .centerX, view: self, on: .centerX)
    dropdownButton.g_pin(on: .bottom, view: self, on: .bottom, constant: -4)
    dropdownButton.addTarget(self, action: #selector(dropdownTouched(_:)), for: .touchUpInside)
  }
  
  fileprivate func clearSubviews() {
    self.flashButton.removeFromSuperview()
    self.rotateButton.removeFromSuperview()
    self.timerLabel.removeFromSuperview()
    self.dropdownButton.removeFromSuperview()
  }

  fileprivate func setupCameraLayout() {
    insertRotate()
    insertFlash()
    insertTimerLabel()
  }

  fileprivate func setupLibraryLayout() {
    insertDropdownButton()
  }
  
  @objc func flashButtonTouched(_ button: UIButton) {
    flashButton.toggle()
    cameraDelegate?.onFlashToggle(selectedIndex: flashButton.selectedIndex)
  }
  
  @objc func rotateButtonTouched(_ button: UIButton) {
    cameraDelegate?.onRotateToggle()
  }
  
  @objc func dropdownTouched(_ button: UIButton) {
    libraryDelegate?.onDropdownTap()
  }
  
  @objc fileprivate func onBackButtonTap() {
    EventHub.shared.close?()
  }
  
  func showTimer() {
    let userInfo = ["start": Date().timeIntervalSince1970]
    self.videoRecordingTimer = Timer.scheduledTimer(
      timeInterval: 0.5, target: self, selector: #selector(videoRecodringTimerFired(_:)), userInfo: userInfo, repeats: true)
    self.timerLabel.fade(visible: true)
  }

  func hideTimer() {
    self.videoRecordingTimer?.invalidate()
    self.timerLabel.fade(visible: false)
    self.timerLabel.text = nil
  }

  @objc func videoRecodringTimerFired(_ timer: Timer) {
    guard let dictionary = timer.userInfo as? [String: Any], let start = dictionary["start"] as? TimeInterval else {
      return
    }

    let now = Date().timeIntervalSince1970
    let minutes = Int(now - start) / 60
    let seconds = Int(now - start) % 60
    self.timerLabel.text = String(format: "%0.2d:%0.2d", minutes, seconds)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

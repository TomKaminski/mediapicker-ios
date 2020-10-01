import UIKit

class BottomView: UIView, GalleryFloatingButtonTapDelegate, BottomViewCartDelegate {
  // MARK: Properties
  
  var videoRecordingTimer: Timer?

  weak var delegate: BottomViewDelegate?

  var backButton: CircularBorderButton?
  var cartView: CartCollectionView?
  var saveButton: GalleryFloatingButton?
  var shutterButton: ShutterButton?
  var elapsedVideoRecordingTimeLabel: UILabel?

  var state: MediaToolbarState = .Camera
  var activeTab: GalleryTab = .libraryTab

  // MARK: Initialization

  required init() {
    super.init(frame: .zero)
    self.backgroundColor = MediaPickerConfig.instance.bottomView.backgroundColor.withAlphaComponent(0.5)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: Delegates implementation
  
  func onItemDelete(guid: String) {
    self.delegate?.onItemRemove(guid: guid)
  }
  
  func closeCartView() {
    setupForActiveTab()
  }
  
  func tapped() {
    EventHub.shared.doneWithMedia?()
  }

  // MARK: Setup

  func setup() {
    switch state {
    case .Camera:
      setupCameraLayout()
    case .CartExpanded:
      setupCartCollectionLayout()
    case .Library:
      setupLibraryLayout()
    case .Audio:
      setupLibraryLayout()
    case .AudioRecording:
      setupAudioRecording()
    }
  }
  
  func setupForActiveTab() {
    switch activeTab {
    case .cameraTab:
      setupCameraLayout()
    case .libraryTab:
      setupLibraryLayout()
    case .audioTab:
      setupLibraryLayout()
    }
  }

  fileprivate func makeBackButton() -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerConfig.instance.bottomView.backButton.icon, for: .normal)
    btn.addTarget(self, action: #selector(onBackButtonTap), for: .touchUpInside)
    return btn
  }

  @objc fileprivate func onBackButtonTap() {
    EventHub.shared.close?()
  }

  fileprivate func makeSaveButton() -> GalleryFloatingButton {
    let button = GalleryFloatingButton()
    button.tapDelegate = self
    button.imageView.image = MediaPickerConfig.instance.bottomView.saveButton.icon

    return button
  }
  
  fileprivate func makeVideoRecordingElapsedTimeLabel() -> UILabel {
    let label = UILabel()
    label.text = self.videoRecordingLabelPlaceholder()
    label.textAlignment = .center
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 10)
    return label
  }
  
  func videoRecordingLabelPlaceholder() -> String {
    return MediaPickerConfig.instance.translationKeys.tapForImageHoldForVideoKey.g_localize(fallback: "Tap for image, hold for video")
  }

  fileprivate func makeShutterButton() -> ShutterButton {
    let shutterBtn = ShutterButton()
    shutterBtn.addTarget(self, action: #selector(onShutterButtonTapped), for: .touchUpInside)

    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(shutterLongTap(sender:)))
    shutterBtn.addGestureRecognizer(longGesture)
    return shutterBtn
  }
  
  @objc fileprivate func shutterLongTap(sender: UIGestureRecognizer) {
    guard MediaPickerConfig.instance.videoRecording.allow else {
      if sender.state == .ended {
        onShutterButtonTapped()
      }
      return
    }
    
    if sender.state == .began {
      self.setupRecordingLayout()
      self.delegate?.shutterButtonHeld()
    } else if sender.state == .ended {
      self.delegate?.shutterButtonReleased()
      self.setupCameraLayout()
    }
  }
  
  fileprivate func setupRecordingLayout() {
    self.shutterButton?.recording = true
    self.backButton?.isHidden = true
  }
  
  @objc fileprivate func onShutterButtonTapped() {
    self.delegate?.shutterButtonTouched()
  }

  fileprivate func clearSubviews() {
    self.shutterButton?.removeFromSuperview()
    self.shutterButton = nil

    self.backButton?.removeFromSuperview()
    self.backButton = nil

    self.saveButton?.removeFromSuperview()
    self.saveButton = nil
    
    self.elapsedVideoRecordingTimeLabel?.removeFromSuperview()
    self.elapsedVideoRecordingTimeLabel = nil

    self.cartView?.removeFromSuperview()
    self.cartView = nil
  }

  fileprivate func setupCartCollectionLayout() {
    clearSubviews()

    let cartView = CartCollectionView(frame: .zero, cartItems: self.delegate!.cartItems)
    self.cartView = cartView
    cartView.bottomViewCartDelegate = self
    cartView.backgroundColor = .black
    addSubview(cartView)
    cartView.g_pinEdges()
  }

  fileprivate func setupCameraLayout() {
    clearSubviews()
    insertShutterButton(recording: false)
    insertSaveButton()
    insertBackButton()
  }

  fileprivate func setupAudioRecording() {
    clearSubviews()
    insertBackButton()
  }

  fileprivate func setupLibraryLayout() {
    clearSubviews()
    insertBackButton()
    insertSaveButton()
  }

  fileprivate func insertShutterButton(recording: Bool) {
    let elapsedVideoRecordingTimeLabel = self.elapsedVideoRecordingTimeLabel ?? self.makeVideoRecordingElapsedTimeLabel()
    self.elapsedVideoRecordingTimeLabel = elapsedVideoRecordingTimeLabel
    addSubview(elapsedVideoRecordingTimeLabel)
    Constraint.on(
      elapsedVideoRecordingTimeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      elapsedVideoRecordingTimeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 2)
    )
    addSubview(elapsedVideoRecordingTimeLabel)
    
    let shutterButton = self.shutterButton ?? self.makeShutterButton()
    self.shutterButton = shutterButton
    self.shutterButton?.isUserInteractionEnabled = true
    shutterButton.recording = recording
    addSubview(shutterButton)
    shutterButton.g_pin(width: MediaPickerConfig.instance.bottomView.shutterButton.size)
    shutterButton.g_pin(height: MediaPickerConfig.instance.bottomView.shutterButton.size)
    Constraint.on(
      shutterButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      shutterButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 8)
    )
  }

  fileprivate func insertSaveButton() {
    let saveButton = self.saveButton ?? self.makeSaveButton()
    self.saveButton = saveButton
    addSubview(saveButton)
    Constraint.on(
      saveButton.trailingAnchor.constraint(equalTo: saveButton.superview!.trailingAnchor, constant: MediaPickerConfig.instance.bottomView.saveButton.rightMargin),
      saveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }

  fileprivate func insertBackButton() {
    let backButton = self.backButton ?? self.makeBackButton()
    self.backButton = backButton
    addSubview(backButton)
    
    Constraint.on(
      backButton.leadingAnchor.constraint(equalTo: backButton.superview!.leadingAnchor, constant: MediaPickerConfig.instance.bottomView.backButton.leftMargin),
      backButton.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.bottomView.backButton.size),
      backButton.widthAnchor.constraint(equalToConstant: MediaPickerConfig.instance.bottomView.backButton.size),
      backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }
  
  func showTimer() {
    let userInfo = ["start": Date().timeIntervalSince1970]
    self.videoRecordingTimer = Timer.scheduledTimer(
      timeInterval: 0.5, target: self, selector: #selector(videoRecodringTimerFired(_:)), userInfo: userInfo, repeats: true)
    self.elapsedVideoRecordingTimeLabel?.text = self.videoRecordingLabelPlaceholder()
  }
  
  func hideTimer() {
    self.videoRecordingTimer?.invalidate()
    self.elapsedVideoRecordingTimeLabel?.text = self.videoRecordingLabelPlaceholder()
  }
  
  @objc func videoRecodringTimerFired(_ timer: Timer) {
    guard let dictionary = timer.userInfo as? [String: Any], let start = dictionary["start"] as? TimeInterval else {
      return
    }
    
    let now = Date().timeIntervalSince1970
    let minutes = Int(now - start) / 60
    let seconds = Int(now - start) % 60
    self.elapsedVideoRecordingTimeLabel?.text = String(format: "%0.2d:%0.2d", minutes, seconds)
  }
}

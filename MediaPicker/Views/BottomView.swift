import UIKit

class BottomView: UIView, GalleryFloatingButtonTapDelegate {
  lazy var shutterButton: ShutterButton = self.makeShutterButton()
  lazy var saveButton: GalleryFloatingButton = self.makeSaveButton()
  lazy var cartButton: StackView = self.makeStackView()

  var state: MediaToolbarState = .Camera
  var activeTab: GalleryTab = .libraryTab {
    didSet {
      setupForActiveTab()
    }
  }
  
  weak var delegate: BottomViewDelegate?


  required init() {
    super.init(frame: .zero)
    self.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func tapped() {
    EventHub.shared.doneWithMediaPicker?()
  }

  // MARK: Setup

  func setup() {
    insertSaveButton()
    insertCartButton()
    
    switch state {
    case .Camera:
      setupCameraLayout()
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

  fileprivate func makeSaveButton() -> GalleryFloatingButton {
    let button = GalleryFloatingButton()
    button.tapDelegate = self
    button.imageView.image = MediaPickerConfig.shared.bottomView.saveIcon
    button.accessibilityIdentifier = "saveButton"

    return button
  }

  fileprivate func makeShutterButton() -> ShutterButton {
    let shutterBtn = ShutterButton()
    shutterBtn.isUserInteractionEnabled = true
    shutterBtn.addTarget(self, action: #selector(onShutterButtonTapped), for: .touchUpInside)

    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(shutterLongTap(sender:)))
    shutterBtn.addGestureRecognizer(longGesture)
    return shutterBtn
  }
  
  @objc fileprivate func shutterLongTap(sender: UIGestureRecognizer) {
    guard MediaPickerConfig.shared.videoRecording.allow else {
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
    self.shutterButton.recording = true
  }
  
  @objc fileprivate func onShutterButtonTapped() {
    self.delegate?.shutterButtonTouched()
  }

  fileprivate func clearSubviews() {
    self.shutterButton.removeFromSuperview()
  }

  fileprivate func setupCameraLayout() {
    clearSubviews()
    insertShutterButton(recording: false)
  }

  fileprivate func setupAudioRecording() {
    clearSubviews()
  }

  fileprivate func setupLibraryLayout() {
    clearSubviews()
  }
  
  fileprivate func makeStackView() -> StackView {
    let stackView = StackView()
    return stackView
  }

  fileprivate func insertShutterButton(recording: Bool) {
    addSubview(shutterButton)
    shutterButton.recording = recording
    shutterButton.g_pin(size: CGSize(width: 56, height: 56))
    shutterButton.g_pinCenter(view: self)
  }

  fileprivate func insertSaveButton() {
    addSubview(saveButton)
    saveButton.g_pin(on: .right, view: self, on: .right, constant: -16)
    saveButton.g_pin(on: .centerY, view: self, on: .centerY)
    saveButton.isHidden = delegate?.cartItems.isEmpty != false
  }
  
  fileprivate func insertCartButton() {
    addSubview(cartButton)
    cartButton.g_pin(size: CGSize(width: 56, height: 56))
    cartButton.g_pin(on: .left, view: self, on: .left, constant: 16)
    cartButton.g_pin(on: .centerY, view: self, on: .centerY)
    cartButton.isHidden = delegate?.cartItems.isEmpty != false
  }
}

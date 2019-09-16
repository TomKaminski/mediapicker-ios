import UIKit

class BottomView: UIView {
  weak var delegate: BottomViewDelegate?

  var backButton: CircularBorderButton?
  var filenameInputView: FilenameInputView?
  var cartView: CartCollectionView?
  var saveButton: GalleryFloatingButton?
  var shutterButton: ShutterButton?

  var state: MediaToolbarState = .Camera
  var activeTab: Config.GalleryTab = .libraryTab

  // MARK: - Initialization

  required init() {
    super.init(frame: .zero)
    self.backgroundColor = Config.BottomView.backgroundColor
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    switch state {
    case .Camera:
      setupCameraLayout()
    case .CartExpanded:
      setupCartCollectionLayout()
    case .VideoTaken:
      setupFilenameInputLayout()
    case .Library:
      setupLibraryLayout()
    case .Audio:
      setupLibraryLayout()
    case .AudioTaken:
      setupFilenameInputLayout()
    case .AudioRecording:
      setupAudioRecording()
    }

    //TODO: Setup layout delegates!!
  }

  func makeBackButton() -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(Config.BottomView.BackButton.icon, for: .normal)
    btn.addTarget(self, action: #selector(onBackButtonTap), for: .touchUpInside)
    return btn
  }

  @objc private func onBackButtonTap() {
    EventHub.shared.close?()
  }

  func makeSaveButton() -> GalleryFloatingButton {
    let button = GalleryFloatingButton()
    button.imageView.image = Config.BottomView.SaveButton.icon

    return button
  }

  func makeShutterButton() -> ShutterButton {
    let shutterBtn = ShutterButton()
    shutterBtn.addTarget(self, action: #selector(onShutterButtonTapped), for: .touchUpInside)

    let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(shutterLongTap(sender:)))
    shutterBtn.addGestureRecognizer(longGesture)
    return shutterBtn
  }
  
  @objc func shutterLongTap(sender: UIGestureRecognizer) {
    if sender.state == .began {
      self.setupRecordingLayout()
      self.delegate?.shutterButtonHeld()
    } else if sender.state == .ended {
      self.delegate?.shutterButtonReleased()
      self.setupCameraLayout()
    }
  }
  
  private func setupRecordingLayout() {
    self.shutterButton?.recording = true
    self.backButton?.isHidden = true
  }
  
  @objc private func onShutterButtonTapped() {
    self.delegate?.shutterButtonTouched()
  }

  func clearSubviews() {
    self.shutterButton?.removeFromSuperview()
    self.shutterButton = nil

    self.backButton?.removeFromSuperview()
    self.backButton = nil

    self.saveButton?.removeFromSuperview()
    self.saveButton = nil

    self.cartView?.removeFromSuperview()
    self.cartView = nil

    self.filenameInputView?.removeFromSuperview()
    self.filenameInputView = nil
  }

  func setupFilenameInputLayout() {
    clearSubviews()
    insertBackButton()
    insertSaveButton()
    insertFileNameInput()
  }

  func setupCartCollectionLayout() {
    clearSubviews()

    let cartView = CartCollectionView(frame: .zero, cartItems: self.delegate!.cartItems)
    self.cartView = cartView
    cartView.backgroundColor = .black
    addSubview(cartView)
    cartView.g_pinEdges()
  }

  func setupCameraLayout() {
    clearSubviews()
    insertShutterButton(recording: false)
    insertSaveButton()
    insertBackButton()
  }

  func setupAudioRecording() {
    clearSubviews()
    insertBackButton()
  }

  func setupLibraryLayout() {
    clearSubviews()
    insertBackButton()
    insertSaveButton()
  }

  fileprivate func insertShutterButton(recording: Bool) {
    let shutterButton = self.shutterButton ?? self.makeShutterButton()
    self.shutterButton = shutterButton
    self.shutterButton?.isUserInteractionEnabled = true
    shutterButton.recording = recording
    addSubview(shutterButton)
    shutterButton.g_pin(width: Config.BottomView.ShutterButton.size)
    shutterButton.g_pin(height: Config.BottomView.ShutterButton.size)
    Constraint.on(
      shutterButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      shutterButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }

  fileprivate func insertSaveButton() {
    let saveButton = self.saveButton ?? self.makeSaveButton()
    self.saveButton = saveButton
    addSubview(saveButton)
    Constraint.on(
      saveButton.trailingAnchor.constraint(equalTo: saveButton.superview!.trailingAnchor, constant: Config.BottomView.SaveButton.rightMargin),
      saveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }

  fileprivate func insertFileNameInput() {
    let filenameInputView = self.filenameInputView ?? FilenameInputView()
    self.filenameInputView = filenameInputView
    addSubview(filenameInputView)
    self.filenameInputView?.attributedPlaceholder = NSAttributedString(string: Config.PhotoEditor.filenameInputPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    Constraint.on(
      filenameInputView.leadingAnchor.constraint(equalTo: self.backButton!.trailingAnchor, constant: 8),
      filenameInputView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }

  fileprivate func insertBackButton() {
    let backButton = self.backButton ?? self.makeBackButton()
    self.backButton = backButton
    addSubview(backButton)
    
    Constraint.on(
      backButton.leadingAnchor.constraint(equalTo: backButton.superview!.leadingAnchor, constant: Config.BottomView.BackButton.leftMargin),
      backButton.heightAnchor.constraint(equalToConstant: Config.BottomView.BackButton.size),
      backButton.widthAnchor.constraint(equalToConstant: Config.BottomView.BackButton.size),
      backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }
}

import UIKit

protocol BottomViewDelegate: AnyObject {
  var itemsInCart: Int { get }
  var cartItems: [CartItemProtocol] { get }

  func bottomView(_ changedStateTo: MediaToolbarState)
  func shutterButtonTouched()
}

class BottomView: UIView {
  weak var delegate: BottomViewDelegate?

  var backButton: UIImageView?
  var filenameInputView: FilenameInputView?
  var cartView: CartCollectionView?
  var saveButton: GalleryFloatingButton?
  var shutterButton: ShutterButton?

  var state: MediaToolbarState = .Camera
  var activeTab: Config.GalleryTab = .libraryTab

  // MARK: - Initialization

  required init() {
    super.init(frame: .zero)
    self.backgroundColor = .black
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
    case .VideoRecording:
      setupCameraRecordingLayout()
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

  func makeBackButton() -> UIImageView {
    let imageView = UIImageView(image: MediaPickerBundle.image("gallery_close"))
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onBackButtonTap)))
    return imageView
  }

  @objc private func onBackButtonTap() {
    EventHub.shared.close?()
  }

  func makeSaveButton() -> GalleryFloatingButton {
    let button = GalleryFloatingButton()
    button.imageView.image = MediaPickerBundle.image("gallery_close")

    return button
  }

  func makeShutterButton() -> ShutterButton {
    let shutterBtn =  ShutterButton()
    shutterBtn.addTarget(self, action: #selector(onShutterButtonTapped), for: .touchUpInside)
    return shutterBtn
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

  func setupCameraRecordingLayout() {
    clearSubviews()
    insertShutterButton(recording: true)
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
    shutterButton.g_pin(width: 55)
    shutterButton.g_pin(height: 55)
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
      saveButton.trailingAnchor.constraint(equalTo: saveButton.superview!.trailingAnchor, constant: -16),
      saveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }

  fileprivate func insertFileNameInput() {
    let filenameInputView = self.filenameInputView ?? FilenameInputView()
    self.filenameInputView = filenameInputView
    addSubview(filenameInputView)
    self.filenameInputView?.attributedPlaceholder = NSAttributedString(string: "Filename here..", attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
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
      backButton.leadingAnchor.constraint(equalTo: backButton.superview!.leadingAnchor, constant: 16),
      backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
    )
  }
}

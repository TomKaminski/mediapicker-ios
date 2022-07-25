protocol BottomToolbarViewControllerDelegate: BottomViewCartDelegate {
  func onBackButtonTap()
}

class BottomToolbarView: UIView, UITextFieldDelegate, CircularButtonConformance, GalleryFloatingButtonTapDelegate {
  func tapped() {
    EventHub.shared.doneWithMedia?()
  }
  
  var cartOpened = false {
    didSet {
      setup()
    }
  }
  
  weak var delegate: BottomViewCartItemsDelegate?
  weak var controllerDelegate: BottomToolbarViewControllerDelegate?
  
  var cartView: CartCollectionView?
  var saveButton: GalleryFloatingButton?
  var filenameInput: FilenameInputView?
  var backButton: CircularBorderButton?
  
  var lastFileName: String? {
    didSet {
      self.filenameInput?.text = lastFileName
    }
  }

  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.endEditing(true)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .black
    self.setup()
  }
  
  func setup() {
    if self.cartOpened {
      setupCartCollectionLayout()
    } else {
      setupLayout()
    }
  }
  
  func makeSaveButton() -> GalleryFloatingButton {    
    let button = GalleryFloatingButton()
    button.imageView.image = MediaPickerConfig.shared.bottomView.saveIcon
    button.tapDelegate = self
    return button
  }
  
  fileprivate func clearSubviews() {
    self.backButton?.removeFromSuperview()
    self.backButton = nil

    self.saveButton?.removeFromSuperview()
    self.saveButton = nil

    self.cartView?.removeFromSuperview()
    self.cartView = nil
    
    self.lastFileName = self.filenameInput?.text ?? self.lastFileName
    self.filenameInput?.removeFromSuperview()
    self.filenameInput = nil
  }
  
  fileprivate func insertSaveButton() {
    let saveButton = self.saveButton ?? self.makeSaveButton()
    self.saveButton = saveButton
    self.saveButton?.translatesAutoresizingMaskIntoConstraints = false
    addSubview(saveButton)
    saveButton.trailingAnchor.constraint(equalTo: saveButton.superview!.trailingAnchor, constant: -16).isActive = true
    saveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  fileprivate func makeBackButton() -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerConfig.shared.bottomView.backButton.icon, for: .normal)
    btn.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
    btn.translatesAutoresizingMaskIntoConstraints = false
    return btn
  }
  
  @objc func onBackPressed() {
    self.controllerDelegate?.onBackButtonTap()
  }
  
  fileprivate func makeFilenameInput() -> FilenameInputView {
    let view = FilenameInputView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = self.lastFileName
    view.delegate = self
    view.attributedPlaceholder = NSAttributedString(string: MediaPickerConfig.shared.translationKeys.filenameInputPlaceholderKey.g_localize(fallback: "Filename.."), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    return view
  }

  fileprivate func insertBackButton() {
    let backButton = self.backButton ?? self.makeBackButton()
    self.backButton = backButton
    addSubview(backButton)
    
    backButton.leadingAnchor.constraint(equalTo: backButton.superview!.leadingAnchor, constant: MediaPickerConfig.shared.bottomView.backButton.leftMargin).isActive = true
    backButton.heightAnchor.constraint(equalToConstant: MediaPickerConfig.shared.bottomView.backButton.size).isActive = true
    backButton.widthAnchor.constraint(equalToConstant: MediaPickerConfig.shared.bottomView.backButton.size).isActive = true
    backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
  }
  
  fileprivate func insertFileNameInput() {
    let fileInputView = self.filenameInput ?? self.makeFilenameInput()
    self.filenameInput = fileInputView
    addSubview(fileInputView)
    fileInputView.leadingAnchor.constraint(equalTo: self.backButton!.trailingAnchor, constant: 12).isActive = true
    fileInputView.trailingAnchor.constraint(equalTo: self.saveButton!.leadingAnchor, constant: -12).isActive = true
    fileInputView.centerYAnchor.constraint(equalTo: self.backButton!.centerYAnchor).isActive = true
  }
  
  fileprivate func setupLayout() {
    clearSubviews()
    insertBackButton()
    insertSaveButton()
    insertFileNameInput()
  }
  
  fileprivate func setupCartCollectionLayout() {
    clearSubviews()

    let cartView = CartCollectionView(frame: .zero, cartItems: self.delegate!.cartItems)
    self.cartView = cartView
    self.cartView?.bottomViewCartDelegate = self.controllerDelegate
    cartView.backgroundColor = .black
    addSubview(cartView)
    cartView.g_pinEdges()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

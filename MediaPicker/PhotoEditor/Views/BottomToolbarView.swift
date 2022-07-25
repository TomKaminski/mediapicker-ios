class BottomToolbarView: UIView, UITextFieldDelegate, GalleryFloatingButtonTapDelegate {
  weak var delegate: MediaEditorControllerDelegate?
  
  var saveButton: GalleryFloatingButton?
  var filenameInput: FilenameInputView?
  
  var lastFileName: String? {
    didSet {
      self.filenameInput?.text = lastFileName
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    clearSubviews()
    insertSaveButton()
    insertFileNameInput()
  }
  
  func tapped() {
//    delegate?.onSaveTapped(item: )
  }
  
  func makeSaveButton() -> GalleryFloatingButton {    
    let button = GalleryFloatingButton()
    button.imageView.image = MediaPickerConfig.shared.bottomView.saveIcon
    button.tapDelegate = self
    return button
  }
  
  fileprivate func clearSubviews() {
    self.saveButton?.removeFromSuperview()
    self.saveButton = nil
    
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
  
  fileprivate func makeFilenameInput() -> FilenameInputView {
    let view = FilenameInputView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.text = self.lastFileName
    view.delegate = self
    view.attributedPlaceholder = NSAttributedString(string: MediaPickerConfig.shared.translationKeys.filenameInputPlaceholderKey.g_localize(fallback: "Filename.."), attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    return view
  }
  
  fileprivate func insertFileNameInput() {
    let fileInputView = self.filenameInput ?? self.makeFilenameInput()
    self.filenameInput = fileInputView
    addSubview(fileInputView)
    fileInputView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12).isActive = true
    fileInputView.trailingAnchor.constraint(equalTo: self.saveButton!.leadingAnchor, constant: -12).isActive = true
    fileInputView.centerYAnchor.constraint(equalTo: self.saveButton!.centerYAnchor).isActive = true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    self.endEditing(true)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

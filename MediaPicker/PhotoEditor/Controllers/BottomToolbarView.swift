class BottomToolbarView: UIView, UITextFieldDelegate {
  lazy var backButton: CircularBorderButton = self.makeCircularButton(with: "arrowLeftIcon")
  lazy var saveButton: GalleryFloatingButton = self.makeSaveButton()
  lazy var filenameInput: FilenameInputView = self.makeInputView()

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
  
  private func setup() {
    self.addSubview(backButton)
    self.addSubview(filenameInput)
    self.addSubview(saveButton)
    
    self.filenameInput.delegate = self
  }
  
  private func makeCircularButton(with imageName: String) -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerBundle.image(imageName), for: .normal)
    
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.widthAnchor.constraint(equalToConstant: Config.PhotoEditor.editorCircularButtonSize).isActive = true
    btn.heightAnchor.constraint(equalToConstant: Config.PhotoEditor.editorCircularButtonSize).isActive = true
    
    return btn
  }
  
  func makeSaveButton() -> GalleryFloatingButton {
    let button = GalleryFloatingButton()
    button.imageView.image = Config.BottomView.SaveButton.icon
    
    return button
  }
  
  func makeInputView() -> FilenameInputView {
    let inputView = FilenameInputView()
    inputView.attributedPlaceholder = NSAttributedString(string: Config.PhotoEditor.filenameInputPlaceholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.gray])
    return inputView
  }
  
  
  
  override func updateConstraints() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.filenameInput.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.backButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -10),
      self.backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
      
      self.filenameInput.leadingAnchor.constraint(equalTo: self.backButton.trailingAnchor, constant: 12),
      self.filenameInput.trailingAnchor.constraint(equalTo: self.saveButton.leadingAnchor, constant: -12),
      self.filenameInput.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor),

      self.saveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
      self.saveButton.centerYAnchor.constraint(equalTo: self.backButton.centerYAnchor)
    ])
    super.updateConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

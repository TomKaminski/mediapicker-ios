protocol MediaPreviewToolbarDelegate: AnyObject {
  func onBackTap()
}

class MediaPreviewToolbar: UIView {
  weak var delegate: MediaPreviewToolbarDelegate?
  
  lazy var buttonsContainerView: UIView = UIView()
  lazy var backButton = self.makeBackButton()
  lazy var fileNameLabel = self.makeFileNameLabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    setup()
  }
  
  private func setup() {
    self.addSubview(buttonsContainerView)
    
    self.translatesAutoresizingMaskIntoConstraints = false
    self.buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.buttonsContainerView.topAnchor.constraint(equalTo: self.topAnchor),
      self.buttonsContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.buttonsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.buttonsContainerView.heightAnchor.constraint(equalToConstant: 40),
    ])
    
    insertBackButton()
    insertMediaFileNameLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func makeBackButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Back"), for: UIControl.State())
    button.addTarget(self, action: #selector(onBackTap), for: .touchUpInside)
    return button
  }
  
  func makeFileNameLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingMiddle
    return label
  }
  
  @objc fileprivate func onBackTap() {
    self.delegate?.onBackTap()
  }
  
  fileprivate func clearSubviews() {
    self.backButton.removeFromSuperview()
    self.fileNameLabel.removeFromSuperview()
  }
  
  fileprivate func insertBackButton() {
    addSubview(backButton)
    backButton.g_pin(on: .left, view: buttonsContainerView, on: .left, constant: 12)
    backButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    backButton.g_pin(width: 24)
  }
  
  fileprivate func insertMediaFileNameLabel() {
    addSubview(fileNameLabel)
    fileNameLabel.g_pin(on: .left, view: backButton, on: .right, constant: 12)
    fileNameLabel.g_pin(on: .right, view: self, on: .right, constant: -12)
    fileNameLabel.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
  }
}

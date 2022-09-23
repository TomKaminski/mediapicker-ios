protocol MediaBaseToolbarDelegate: AnyObject {
  func onBackTap()
  func onLabelTap()
}

protocol MediaPreviewToolbarDelegate: MediaBaseToolbarDelegate {
  func onEditTap()
}

class MediaPreviewToolbar: UIView {
  weak var delegate: MediaPreviewToolbarDelegate?
  
  lazy var buttonsContainerView: UIView = UIView()
  lazy var backButton = self.makeBackButton()
  lazy var fileNameLabel = self.makeFileNameLabel()
  lazy var editButton = self.makeEditButton()
  
  var canEditCurrentItem: Bool = true {
    didSet {
      toggleEditButton()
    }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    setup()
  }
  
  private func setup() {
    addSubview(buttonsContainerView)
    
    translatesAutoresizingMaskIntoConstraints = false
    buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      buttonsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
      buttonsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
      buttonsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
      buttonsContainerView.heightAnchor.constraint(equalToConstant: 40),
    ])
    
    insertBackButton()
    insertMediaFileNameLabel()
    insertEditButton()
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
  
  func makeEditButton() -> UIButton {
    let button = UIButton()
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Edit", for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
    button.addTarget(self, action: #selector(onEditTap), for: .touchUpInside)
    return button
  }
  
  func makeFileNameLabel() -> UILabel {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 1
    label.lineBreakMode = .byTruncatingMiddle
    label.isUserInteractionEnabled = true
    label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onLabelTap)))
    return label
  }
  
  @objc fileprivate func onBackTap() {
    delegate?.onBackTap()
  }
  
  @objc fileprivate func onEditTap() {
    if canEditCurrentItem {
      delegate?.onEditTap()
    }
  }
  
  @objc fileprivate func onLabelTap() {
    delegate?.onLabelTap()
  }
  
  fileprivate func toggleEditButton() {
    editButton.isHidden = !canEditCurrentItem
  }
  
  fileprivate func clearSubviews() {
    backButton.removeFromSuperview()
    fileNameLabel.removeFromSuperview()
  }
  
  fileprivate func insertBackButton() {
    addSubview(backButton)
    backButton.g_pin(on: .left, view: buttonsContainerView, on: .left, constant: 12)
    backButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    backButton.g_pin(size: CGSize(width: 30, height: 40))
  }
  
  fileprivate func insertMediaFileNameLabel() {
    addSubview(fileNameLabel)
    fileNameLabel.g_pin(on: .left, view: backButton, on: .right, constant: 12)
    fileNameLabel.g_pin(on: .right, view: self, on: .right, constant: -12)
    fileNameLabel.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
  }
  
  fileprivate func insertEditButton() {
    addSubview(editButton)
    editButton.g_pin(on: .right, view: buttonsContainerView, on: .right, constant: -12)
    editButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    editButton.g_pin(height: 40)
  }
}

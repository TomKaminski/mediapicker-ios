protocol TopToolbarViewDelegate: MediaPreviewToolbarDelegate {
  func onTextTap()
  func onClearTap()
  func onPencilTap()
  
  func didSelectColor(color: UIColor)
}

class PhotoEditorToolbar: UIView, ColorSelectedDelegate {
  var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
  weak var editorViewDelegate: TopToolbarViewDelegate?
  
  lazy var colorsCollectionView: UICollectionView = self.makeColorsCollectionView()
  lazy var buttonsContainerView: UIView = UIView()
  
  lazy var undoButton = self.makeUndoButton()
  lazy var textButton = self.makeTextButton()
  lazy var pencilButton = self.makePencilButton()
  lazy var backButton = self.makeBackButton()
  lazy var fileNameLabel = self.makeFileNameLabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    setup()
  }
  
  private func setup() {
    self.addSubview(buttonsContainerView)
    self.addSubview(colorsCollectionView)
    
    self.translatesAutoresizingMaskIntoConstraints = false
    self.colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
    self.buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.buttonsContainerView.topAnchor.constraint(equalTo: self.topAnchor),
      self.buttonsContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.buttonsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.buttonsContainerView.heightAnchor.constraint(equalToConstant: 40),

      self.colorsCollectionView.topAnchor.constraint(equalTo: self.buttonsContainerView.bottomAnchor),
      self.colorsCollectionView.heightAnchor.constraint(equalToConstant: 40),
      self.colorsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.colorsCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
    ])
    
    insertBackButton()
    insertTextButton()
    insertPencilButton()
    insertUndoButton()
    insertMediaFileNameLabel()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func makeColorsCollectionView() -> UICollectionView {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 10
    
    let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
    colorsCollectionViewDelegate.colorDelegate = self
    colView.delegate = colorsCollectionViewDelegate
    colView.dataSource = colorsCollectionViewDelegate
    colView.backgroundColor = UIColor.clear
    colView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCollectionViewCell")
    colView.showsHorizontalScrollIndicator = false
    
    return colView
  }
  
  func makeBackButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Back"), for: UIControl.State())
    button.addTarget(self, action: #selector(onBackTap), for: .touchUpInside)
    return button
  }
  
  func makeTextButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Text"), for: UIControl.State())
    button.addTarget(self, action: #selector(onTextTap), for: .touchUpInside)
    return button
  }
  
  func makePencilButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Pencil"), for: UIControl.State())
    button.addTarget(self, action: #selector(onPencilTap), for: .touchUpInside)
    return button
  }
  
  func makeUndoButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Undo"), for: UIControl.State())
    button.addTarget(self, action: #selector(onClearTap), for: .touchUpInside)
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
  
  @objc fileprivate func onTextTap() {
    self.editorViewDelegate?.onTextTap()
  }
  
  @objc fileprivate func onClearTap() {
    self.editorViewDelegate?.onClearTap()
  }
  
  @objc fileprivate func onBackTap() {
    self.editorViewDelegate?.onBackTap()
  }
  
  @objc fileprivate func onPencilTap() {
    self.editorViewDelegate?.onPencilTap()
  }
  
  func didSelectColor(color: UIColor) {
    self.editorViewDelegate?.didSelectColor(color: color)
  }
  
  fileprivate func clearSubviews() {
    self.pencilButton.removeFromSuperview()
    self.backButton.removeFromSuperview()
    self.undoButton.removeFromSuperview()
    self.textButton.removeFromSuperview()
    self.colorsCollectionView.removeFromSuperview()
    self.fileNameLabel.removeFromSuperview()
  }
  
  fileprivate func insertBackButton() {
    addSubview(backButton)
    backButton.g_pin(on: .left, view: buttonsContainerView, on: .left, constant: 12)
    backButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    backButton.g_pin(width: 24)
  }
  
  fileprivate func insertUndoButton() {
    addSubview(undoButton)
    undoButton.g_pin(on: .right, view: pencilButton, on: .left, constant: -12)
    undoButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    undoButton.g_pin(width: 24)
  }
  
  fileprivate func insertPencilButton() {
    addSubview(pencilButton)
    pencilButton.g_pin(on: .right, view: textButton, on: .left, constant: -12)
    pencilButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    pencilButton.g_pin(width: 24)
  }
  
  fileprivate func insertTextButton() {
    addSubview(textButton)
    textButton.g_pin(on: .right, view: buttonsContainerView, on: .right, constant: -12)
    textButton.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
    textButton.g_pin(width: 24)
  }
  
  fileprivate func insertMediaFileNameLabel() {
    addSubview(fileNameLabel)
    fileNameLabel.g_pin(on: .left, view: backButton, on: .right, constant: 12)
    fileNameLabel.g_pin(on: .right, view: undoButton, on: .left, constant: -12)
    fileNameLabel.g_pin(on: .centerY, view: buttonsContainerView, on: .centerY)
  }
}

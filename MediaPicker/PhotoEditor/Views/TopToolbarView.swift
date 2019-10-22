protocol TopToolbarViewDelegate: class {
  func textButtonTapped(_ sender: Any)
  func clearButtonTapped(_ sender: Any)
  func didSelectColor(color: UIColor)
}

class TopToolbarView: UIView, ColorSelectedDelegate, CircularButtonConformance {
  var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!
  weak var editorViewDelegate: TopToolbarViewDelegate?
  
  lazy var colorsCollectionView: UICollectionView = self.makeColorsCollectionView()
  lazy var buttonsContainerView: UIView = UIView()
  
  lazy var undoButton: CircularBorderButton = self.makeCircularButton(with: "undoIcon")
  lazy var textButton: CircularBorderButton = self.makeCircularButton(with: "textIcon")

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = .black
    self.setup()
  }
  
  private func setup() {
    self.addSubview(colorsCollectionView)
    self.addSubview(buttonsContainerView)
    
    self.buttonsContainerView.addSubview(undoButton)
    self.buttonsContainerView.addSubview(textButton)
    
    textButton.addTarget(self, action: #selector(textButtonTapped(_:)), for: .touchUpInside)
    undoButton.addTarget(self, action: #selector(clearButtonTapped(_:)), for: .touchUpInside)
  }
  
  override func updateConstraints() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.colorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
    self.buttonsContainerView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
        self.colorsCollectionView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        self.colorsCollectionView.heightAnchor.constraint(equalToConstant: 40),
        self.colorsCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
        self.colorsCollectionView.trailingAnchor.constraint(equalTo: self.buttonsContainerView.leadingAnchor, constant: 12),
        self.buttonsContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        self.buttonsContainerView.heightAnchor.constraint(equalToConstant: 50),
        self.buttonsContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
        self.buttonsContainerView.widthAnchor.constraint(equalToConstant: 88),
        self.undoButton.leadingAnchor.constraint(equalTo: self.buttonsContainerView.leadingAnchor),
        self.textButton.leadingAnchor.constraint(equalTo: self.undoButton.trailingAnchor, constant: 8)
    ])
    super.updateConstraints()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func makeColorsCollectionView() -> UICollectionView {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 30, height: 30)
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    
    let colView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
    colorsCollectionViewDelegate.colorDelegate = self
    colView.delegate = colorsCollectionViewDelegate
    colView.dataSource = colorsCollectionViewDelegate
    colView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: "ColorCollectionViewCell")
    
    return colView
  }
  
  func didSelectColor(color: UIColor) {
    self.editorViewDelegate?.didSelectColor(color: color)
  }
  
  @objc func textButtonTapped(_ sender: Any) {
    self.editorViewDelegate?.textButtonTapped(sender)
  }
  
  @objc func clearButtonTapped(_ sender: Any) {
    self.editorViewDelegate?.clearButtonTapped(sender)
  }
}

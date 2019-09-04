class EditorCanvasView: UIView {
  lazy var imageView: UIImageView = UIImageView()
  lazy var canvasView: UIView = UIView()
  
  var imageViewHeightConstraint: NSLayoutConstraint!

  fileprivate func getImageSuitableSize(_ image: UIImage) -> CGSize {
    return image.suitableSize(widthLimit: UIScreen.main.bounds.width)!
  }
  
  public func setImage(_ image: UIImage) {
    let size = getImageSuitableSize(image)
    imageViewHeightConstraint.constant = size.height
    self.imageView.image = image
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    imageViewHeightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: 680)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    [imageView, canvasView].forEach { self.addSubview($0) }
    
    imageView.contentMode = .scaleAspectFit
  }
  
  override func updateConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    
    
    NSLayoutConstraint.activate([
      self.imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      imageViewHeightConstraint,
      self.canvasView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.canvasView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.canvasView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      self.canvasView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor)
    ])
    
    super.updateConstraints()
  }
}

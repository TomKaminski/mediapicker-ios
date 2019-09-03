public class EditorView: UIView {
  lazy var topToolbarView: TopToolbarView = TopToolbarView()
  lazy var centerView: UIImageView = UIImageView()
  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  lazy var addPhotoButton: CircularBorderButton = self.makeCircularButton(with: "addPhotoIcon")

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.black
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    [topToolbarView, centerView, bottomToolbarView, addPhotoButton].forEach { self.addSubview($0) }
    
    centerView.contentMode = .scaleAspectFit
  }
  
  private func makeCircularButton(with imageName: String) -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerBundle.image(imageName), for: .normal)
    
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
    btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    return btn
  }
  
  public override func updateConstraints() {
    topToolbarView.translatesAutoresizingMaskIntoConstraints = false
    centerView.translatesAutoresizingMaskIntoConstraints = false
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      self.topToolbarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.topToolbarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.topToolbarView.topAnchor.constraint(equalTo: self.topAnchor),
      self.topToolbarView.heightAnchor.constraint(equalToConstant: 60),

      self.centerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.centerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.centerView.topAnchor.constraint(equalTo: self.topToolbarView.bottomAnchor),
      self.centerView.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor),

      self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.bottomToolbarView.heightAnchor.constraint(equalToConstant: 120),
      
      self.addPhotoButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
      self.addPhotoButton.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor, constant: -8)
    ])

    
    super.updateConstraints()
  }
  
  public func setImage(_ image: UIImage) {
    self.centerView.image = image
  }
}

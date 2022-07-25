public protocol GalleryFloatingButtonTapDelegate: AnyObject {
  func tapped()
}

public class GalleryFloatingButton: UIView {
  public var imageView: UIImageView!
  public weak var tapDelegate: GalleryFloatingButtonTapDelegate?
  
  override public init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = MediaPickerConfig.shared.colors.primary
    self.layer.cornerRadius = 28
    self.layer.masksToBounds = true
    self.isUserInteractionEnabled = true
    
    imageView = UIImageView(frame: .zero)
    imageView.contentMode = .scaleAspectFit
    self.addSubview(imageView)
    
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(buttonTapped))
    self.addGestureRecognizer(gestureRecognizer)
  }
  
  override public func updateConstraints() {
    self.translatesAutoresizingMaskIntoConstraints = false
    self.imageView.translatesAutoresizingMaskIntoConstraints = false
    
    self.heightAnchor.constraint(equalToConstant: 56).isActive = true
    self.widthAnchor.constraint(equalToConstant: 56).isActive = true
    self.imageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    self.imageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    
    self.imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    self.imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    
    super.updateConstraints()
  }
  
  @objc private func buttonTapped() {
    self.tapDelegate?.tapped()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

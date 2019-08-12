protocol CartButtonDelegate: AnyObject {
  func cartButtonTapped()
}

class CartButton: UIView {
  var cartOpenedImage: UIImageView = UIImageView(image: MediaPickerBundle.image("gallery_close"))
  var cartItemsLabel: UILabel = UILabel()
  
  weak var delegate: CartButtonDelegate?
  
  var cartOpened: Bool = false {
    didSet {
      toggleVisibility()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.53)
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 20
    
    cartItemsLabel.textColor = .white
    cartItemsLabel.text = "0"
    cartItemsLabel.textAlignment = .center
    cartItemsLabel.font = UIFont.systemFont(ofSize: 18, weight: .light)
    cartOpenedImage.contentMode = .scaleAspectFit
    
    self.isUserInteractionEnabled = true
    self.addSubview(cartOpenedImage)
    self.addSubview(cartItemsLabel)
    toggleVisibility()
    
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
  }
  
  @objc private func tapped() {
    self.delegate?.cartButtonTapped()
  }
  
  override func updateConstraints() {
    self.cartOpenedImage.g_pinEdges()
    self.cartItemsLabel.g_pinEdges()
    
    super.updateConstraints()
  }
  
  public func updateCartItemsLabel(_ items: Int) {
    cartItemsLabel.text = "\(items)"
  }
  
  private func toggleVisibility() {
    if cartOpened {
      self.cartOpenedImage.isHidden = false
      self.cartItemsLabel.isHidden = true
    } else {
      self.cartOpenedImage.isHidden = true
      self.cartItemsLabel.isHidden = false
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

protocol CartButtonDelegate: AnyObject {
  func cartButtonTapped()
}

class CartButton: UIView {
  var cartOpenedImage: UIImageView = UIImageView(image: Config.CartButton.cartExpandedImage)
  var cartItemsLabel: UILabel = UILabel()
  
  weak var delegate: CartButtonDelegate?
  
  var cartOpened: Bool = false {
    didSet {
      toggleVisibility()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    setupCartItemsLabel()
    cartOpenedImage.contentMode = .scaleAspectFit
    
    self.addSubview(cartOpenedImage)
    self.addSubview(cartItemsLabel)
    
    toggleVisibility()
    
    self.isHidden = true
  }
  
  override func updateConstraints() {
    self.cartOpenedImage.g_pinEdges()
    self.cartItemsLabel.g_pinEdges()
    
    super.updateConstraints()
  }
  
  public func updateCartItemsLabel(_ items: Int, _ cartOpened: Bool = false) {
    cartItemsLabel.text = "\(items)"
    self.isHidden = items == 0
    //self.cartOpened = cartOpened
  }
  
  @objc private func tapped() {
    self.delegate?.cartButtonTapped()
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
  
  fileprivate func setupCartItemsLabel() {
    cartItemsLabel.textColor = Config.CartButton.textColor
    cartItemsLabel.text = "0"
    cartItemsLabel.textAlignment = .center
    cartItemsLabel.font = Config.CartButton.font
  }
  
  fileprivate func setup() {
    self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.53)
    self.layer.borderColor = Config.CartButton.textColor.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 20
    self.isUserInteractionEnabled = true
    
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

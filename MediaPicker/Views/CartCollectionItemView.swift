public class CartCollectionItemView: UIView {
  weak var delegate: CartCollectionViewDelegate?
  
  var type: MediaTypeEnum!
  var bottomText: String?
  var bottomTextFunc: ((UILabel) -> Void)?
  var imageView: UIImageView!
  var bottomView: UIView!
  var deleteButon: UIImageView!
  var guid: String!
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    layer.borderWidth = 1
    layer.borderColor = UIColor.clear.cgColor
    backgroundColor = .white

    setupImageView()
    setupDeleteButton()
    
    addSubview(imageView)
    addSubview(deleteButon)
    
    deleteButon.g_pin(size: CGSize(width: 20, height: 20))
    imageView.g_pinEdges()

    deleteButon.topAnchor.constraint(equalTo: self.topAnchor, constant: 3).isActive = true
    deleteButon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -3).isActive = true
    
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
    
    self.layer.cornerRadius = 4
    self.clipsToBounds = true
  }
  
  fileprivate func setupDeleteButton() {
    deleteButon = UIImageView(image: MediaPickerBundle.image("Delete")?.imageWithInsets(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)))
    deleteButon.contentMode = .scaleAspectFit
    deleteButon.backgroundColor = MediaPickerConfig.shared.colors.red
    deleteButon.layer.cornerRadius = 10
    deleteButon.isUserInteractionEnabled = true
    deleteButon.translatesAutoresizingMaskIntoConstraints = false
    deleteButon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteTapped)))
  }
  
  fileprivate func setupBottomView() {
    bottomView = UIView()
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    bottomView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
  }
  
  fileprivate func setupImageView() {
    imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
  }
  
  @objc private func onDeleteTapped() {
    delegate?.onItemDelete(guid: guid)
  }
  
  @objc private func onTapped() {
    delegate?.onItemTap(guid: guid)
  }

  convenience init(type: MediaTypeEnum, guid: String, image: UIImage, bottomTextFunc: ((UILabel) -> Void)? = nil) {
    self.init(frame: .zero)
    self.type = type
    self.guid = guid
    self.bottomTextFunc = bottomTextFunc
    
    setupBottom(type)

    imageView.image = image
  }

  fileprivate func setupBottom(_ type: MediaTypeEnum) {
    if type != .Image || (self.bottomText != nil || self.bottomTextFunc != nil) {
      setupBottomView()
      addSubview(bottomView)
      bottomView.g_pin(height: 12)
      bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
      bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
    if self.bottomText != nil || self.bottomTextFunc != nil {
      let label = UILabel()
      label.text = bottomText
      label.textColor = .white
      label.font = UIFont.systemFont(ofSize: 7)
      
      self.bottomTextFunc?(label)
      
      bottomView.addSubview(label)
      label.g_pin(height: 10)
      label.rightAnchor.constraint(equalTo: self.bottomView.rightAnchor, constant: -4).isActive = true
      label.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor).isActive = true
    }
  }
  
  convenience init(type: MediaTypeEnum, guid: String, imageCompletion: (UIImageView) -> Void, bottomTextFunc: ((UILabel) -> Void)? = nil) {
    self.init(frame: .zero)
    self.guid = guid
    self.type = type
    self.bottomTextFunc = bottomTextFunc
    
    imageCompletion(self.imageView)
    
    setupBottom(type)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

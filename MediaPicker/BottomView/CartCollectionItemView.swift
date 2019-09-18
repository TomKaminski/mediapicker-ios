public class CartCollectionItemView: UIView {
  var imageView: UIImageView!
  var bottomView: UIView!
  var deleteButon: UIImageView!
  var guid: String!

  var selected: Bool = false {
    didSet {
      setupBorder()
    }
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.borderWidth = 1
    backgroundColor = .white

    setupImageView()
    setupDeleteButton()
    setupBottomView()
    
    self.addSubview(imageView)
    self.addSubview(deleteButon)
    self.addSubview(bottomView)
    
    bottomView.g_pin(height: 16)
    deleteButon.g_pin(size: CGSize(width: 24, height: 24))
    imageView.g_pinEdges()

    Constraint.on(
      deleteButon.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
      deleteButon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2),
      
      bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
    )
    
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTapped)))
  }
  
  fileprivate func setupDeleteButton() {
    deleteButon = UIImageView(image: MediaPickerBundle.image("trashIcon")?.imageWithInsets(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)))
    deleteButon.backgroundColor = .red
    deleteButon.layer.cornerRadius = 12
    deleteButon.isUserInteractionEnabled = true
    deleteButon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteTapped)))
  }
  
  fileprivate func setupBottomView() {
    bottomView = UIView()
    bottomView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
  }
  
  fileprivate func setupImageView() {
    imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
  }
  
  @objc private func onDeleteTapped() {
    EventHub.shared.selfDeleteFromCart?(guid)
  }
  
  @objc private func onTapped() {
    EventHub.shared.executeCustomAction?(guid)
  }

  convenience init(guid: String,image: UIImage) {
    self.init(frame: .zero)
    imageView.image = image
    self.guid = guid
  }

  convenience init(guid: String, imageCompletion: (UIImageView) -> Void) {
    self.init(frame: .zero)
    self.guid = guid

    imageCompletion(self.imageView)
  }

  private func setupBorder() {
    if selected {
      self.layer.borderColor = UIColor.blue.cgColor
    } else {
      self.layer.borderColor = UIColor.white.cgColor
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

public class CartCollectionItemView: UIView {
  var imageView: UIImageView!
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
    
    self.addSubview(imageView)
    self.addSubview(deleteButon)

    deleteButon.g_pin(size: CGSize(width: 15, height: 15))
    imageView.g_pinEdges()

    Constraint.on(
      deleteButon.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
      deleteButon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2)
    )
  }
  
  fileprivate func setupDeleteButton() {
    deleteButon = UIImageView(image: MediaPickerBundle.image("gallery_close"))
    deleteButon.isUserInteractionEnabled = true
    deleteButon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onDeleteTapped)))
  }
  
  fileprivate func setupImageView() {
    imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
  }
  
  @objc private func onDeleteTapped() {
    EventHub.shared.selfDeleteFromCart?(guid)
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

  //TO I TAK JEST BEZ SENSU BO DESIGN NIE MA SENSU TUTAJ
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

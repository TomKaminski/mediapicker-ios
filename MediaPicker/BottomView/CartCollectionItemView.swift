public class CartCollectionItemView: UIView {
  var imageView: UIImageView!
  var deleteButon: UIImageView!
  
  var selected: Bool = false {
    didSet {
      setupBorder()
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    self.layer.borderWidth = 2
    backgroundColor = .green
    
    imageView = UIImageView(image: MediaPickerBundle.image("gallery_camera_flash_auto"))
    imageView.contentMode = .scaleAspectFit
    deleteButon = UIImageView(image: MediaPickerBundle.image("gallery_close"))
    
    self.addSubview(imageView)
    self.addSubview(deleteButon)
    
    imageView.g_pinEdges()
    deleteButon.g_pin(size: CGSize(width: 15, height: 15))
    Constraint.on(
      deleteButon.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
      deleteButon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2)
    )
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

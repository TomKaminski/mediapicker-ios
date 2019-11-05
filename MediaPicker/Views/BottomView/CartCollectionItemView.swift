public class CartCollectionItemView: UIView {
  weak var delegate: CartCollectionViewDelegate?
  
  var type: MediaTypeEnum!
  var bottomText: String?
  var bottomTextFunc: ((UILabel) -> Void)?
  
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
    
    self.addSubview(imageView)
    self.addSubview(deleteButon)
    
    deleteButon.g_pin(size: CGSize(width: 24, height: 24))
    imageView.g_pinEdges()

    Constraint.on(
      deleteButon.topAnchor.constraint(equalTo: self.topAnchor, constant: 2),
      deleteButon.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2)
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
    self.delegate?.onItemDelete(guid: guid)
  }
  
  @objc private func onTapped() {
    if Config.BottomView.Cart.selectedGuid != guid && canTap() {
      EventHub.shared.modalDismissed?(false)
      delegate?.reselectItem()
      EventHub.shared.executeCustomAction?(guid)
    }
  }
  
  private func canTap() -> Bool {
    switch self.type {
      case .Image:
        return Config.Camera.allowPhotoEdit
      case .Audio:
        return Config.Audio.allowAudioEdit
      case .Video:
        return Config.Camera.allowVideoEdit
      case .none:
        return false
    }
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
      self.addSubview(bottomView)
      bottomView.g_pin(height: 16)
      
      Constraint.on(
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
      )
    }
    
    if type != .Image {
      let bottomImageView = UIImageView()
      bottomImageView.contentMode = .scaleAspectFit
      bottomImageView.image = getImage(type)
      
      bottomView.addSubview(bottomImageView)
      bottomImageView.g_pin(height: 12)

      Constraint.on(constraints: [
        bottomImageView.leftAnchor.constraint(equalTo: self.bottomView.leftAnchor, constant: 4),
        bottomImageView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor)
      ])
    }
    
    if self.bottomText != nil || self.bottomTextFunc != nil {
      let label = UILabel()
      label.text = bottomText
      label.textColor = .white
      label.font = UIFont.systemFont(ofSize: 9)
      
      self.bottomTextFunc?(label)
      
      bottomView.addSubview(label)
      label.g_pin(height: 12)
      
      Constraint.on(constraints: [
        label.rightAnchor.constraint(equalTo: self.bottomView.rightAnchor, constant: -4),
        label.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor)
      ])
    }
  }
  
  fileprivate func getImage(_ type: MediaTypeEnum) -> UIImage? {
    return type == .Video ? MediaPickerBundle.image("gallery_video_cell_camera") : MediaPickerBundle.image("recordingMiniatureIcon")
  }
  
  convenience init(type: MediaTypeEnum, guid: String, imageCompletion: (UIImageView) -> Void, bottomTextFunc: ((UILabel) -> Void)? = nil) {
    self.init(frame: .zero)
    self.guid = guid
    self.type = type
    self.bottomTextFunc = bottomTextFunc
    
    imageCompletion(self.imageView)
    
    setupBottom(type)
  }

  private func setupBorder() {
    if selected {
      self.layer.borderColor = UIColor.blue.cgColor
    } else {
      self.layer.borderColor = UIColor.clear.cgColor
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

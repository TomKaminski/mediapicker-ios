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
  }
  
  fileprivate func setupDeleteButton() {
    deleteButon = UIImageView(image: MediaPickerBundle.image("trashIcon")?.imageWithInsets(insets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)))
    deleteButon.backgroundColor = UIColor(red: 196/255, green: 60/255, blue: 53/255, alpha: 1)
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
    if MediaPickerConfig.instance.bottomView.cart.selectedGuid != guid && canTap() {
      EventHub.shared.modalDismissed?(MediaPickerConfig.instance.bottomView.cart.selectedGuid != nil)
      delegate?.reselectItem()
      EventHub.shared.executeCustomAction?(guid)
    }
  }
  
  private func canTap() -> Bool {
    switch self.type {
      case .Image:
        return MediaPickerConfig.instance.camera.allowPhotoEdit
      case .Audio:
        return MediaPickerConfig.instance.audio.allowAudioEdit
      case .Video:
        return MediaPickerConfig.instance.camera.allowVideoEdit
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
      addSubview(bottomView)
      bottomView.g_pin(height: 16)
      bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
      bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
      bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    }
    
    if type != .Image {
      let bottomImageView = UIImageView()
      bottomImageView.contentMode = .scaleAspectFit
      bottomImageView.image = getImage(type)
      
      bottomView.addSubview(bottomImageView)
      bottomImageView.g_pin(height: 12)
      bottomImageView.leftAnchor.constraint(equalTo: self.bottomView.leftAnchor, constant: 4).isActive = true
      bottomImageView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor).isActive = true
    }
    
    if self.bottomText != nil || self.bottomTextFunc != nil {
      let label = UILabel()
      label.text = bottomText
      label.textColor = .white
      label.font = UIFont.systemFont(ofSize: 9)
      
      self.bottomTextFunc?(label)
      
      bottomView.addSubview(label)
      label.g_pin(height: 12)
      label.rightAnchor.constraint(equalTo: self.bottomView.rightAnchor, constant: -4).isActive = true
      label.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor).isActive = true
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
    layer.borderColor = selected ? MediaPickerConfig.instance.colors.primary.cgColor : UIColor.clear.cgColor
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

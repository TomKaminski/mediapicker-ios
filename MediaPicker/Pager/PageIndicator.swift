import UIKit

class PageIndicator: UIView, PageIndicatorUIViewDelegate {
  var buttons: [PageIndicatorUIView]!
  var indicator = UIView()
  
  weak var delegate: PageIndicatorDelegate?
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
        
    for (i, button) in buttons.enumerated() {
      button.frame = CGRect(x: 90 * CGFloat(i), y: 0, width: 90, height: bounds.size.height)
    }
    
    indicator.backgroundColor = MediaPickerConfig.instance.colors.primary
    indicator.layer.cornerRadius = 2
    indicator.frame.size = CGSize(width: 90, height: 4)
    indicator.frame.origin.y = bounds.size.height - indicator.frame.size.height
    
    if indicator.frame.origin.x == 0 {
      select(index: 0)
    }
  }
  
  func setup() {
    let libButton = PageIndicatorUIView(icon: "cameraIcon", text: MediaPickerConfig.instance.translationKeys.libraryTabTitleKey.g_localize(fallback: "LIBRARY"), index: 0)
    libButton.delegate = self
    addSubview(libButton)
    
    let cameraButton = PageIndicatorUIView(icon: "cameraIcon", text: MediaPickerConfig.instance.translationKeys.libraryTabTitleKey.g_localize(fallback: "CAMERA"), index: 1)
    cameraButton.delegate = self
    addSubview(cameraButton)

    let audioButton = PageIndicatorUIView(icon: "cameraIcon", text: MediaPickerConfig.instance.translationKeys.libraryTabTitleKey.g_localize(fallback: "AUDIO"), index: 2)
    audioButton.delegate = self
    addSubview(audioButton)

    buttons = [libButton, cameraButton, audioButton]
    
    addSubview(indicator)
  }
  
  func makeButton(_ title: String) -> PageIndicatorUIView {
    return PageIndicatorUIView(icon: "cameraIcon", text: title, index: 0)
  }
  
  func onTap(index: Int) {
    delegate?.pageIndicator(self, didSelect: index)
  }
  
  func select(index: Int, animated: Bool = true) {
    for (i, b) in buttons.enumerated() {
      b.label.textColor = i == index ? MediaPickerConfig.instance.colors.primary : MediaPickerConfig.instance.colors.black
      b.imageView.image = b.imageView.image?.withTintColor(i == index ? MediaPickerConfig.instance.colors.primary : MediaPickerConfig.instance.colors.black)
    }
    
    UIView.animate(withDuration: animated ? 0.25 : 0.0, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .beginFromCurrentState, animations: {
      self.indicator.center.x = self.buttons[index].center.x
    }, completion: nil)
  }
}

protocol PageIndicatorUIViewDelegate: AnyObject {
  func onTap(index: Int)
}

class PageIndicatorUIView: UIView {
  let index: Int
  
  let imageView = UIImageView()
  let label = UILabel()
  
  weak var delegate: PageIndicatorUIViewDelegate?
  
  public init(icon: String, text: String, index: Int) {
    self.index = index
    
    super.init(frame: .zero)
    
    self.isUserInteractionEnabled = true
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onTap)))
        
    addSubview(imageView)
    imageView.image = MediaPickerBundle.image(icon)?.withTintColor(.black)
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
    imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true

    addSubview(label)
    label.text = text
    label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    label.textAlignment = .center
    label.translatesAutoresizingMaskIntoConstraints = false
    label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
    label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
    label.topAnchor.constraint(equalTo: self.imageView.bottomAnchor, constant: 8).isActive = true
  }
  
  @objc private func onTap() {
    delegate?.onTap(index: index)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

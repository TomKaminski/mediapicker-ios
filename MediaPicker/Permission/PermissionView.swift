import UIKit

class PermissionView: UIView {
  
  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()
  lazy var closeButton: UIButton = self.makeCloseButton()
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.white
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  func setup() {
    [label, settingButton, closeButton, imageView].forEach {
      addSubview($0)
    }
    
    closeButton.g_pin(on: .topMargin)
    closeButton.g_pin(on: .left)
    closeButton.g_pin(size: CGSize(width: 44, height: 44))
    
    settingButton.g_pinCenter()
    settingButton.g_pin(height: 44)
    
    label.g_pin(on: .bottom, view: settingButton, on: .top, constant: -24)
    label.g_pinHorizontally(padding: 50)
    
    imageView.g_pin(on: .centerX)
    imageView.g_pin(on: .bottom, view: label, on: .top, constant: -16)
  }
  
  // MARK: - Controls
  
  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 14)
    label.text = Config.Permission.labelText
    
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    
    return label
  }
  
  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle(Config.Permission.goToSettingsText, for: UIControl.State())
    button.backgroundColor = .blue
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.setTitleColor(.white, for: UIControl.State())
    button.layer.cornerRadius = 22
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    return button
  }
  
  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(Config.Permission.closeImage?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
    button.tintColor = Config.Permission.closeImageTint
    return button
  }
  
  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = Config.Permission.image
    
    return view
  }
}

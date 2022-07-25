import UIKit

class PermissionView: UIView {
  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()
  lazy var closeButton: UIButton = self.makeCloseButton()
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  func setup() {
    [label, settingButton, closeButton, imageView].forEach {
      addSubview($0)
    }
    
    closeButton.g_pin(on: .topMargin)
    closeButton.g_pin(on: .left)
    closeButton.g_pin(size: CGSize(width: 44, height: 44))
    
    settingButton.g_pinCenter()
    settingButton.g_pin(height: 46)
    
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
    label.text = MediaPickerConfig.shared.translationKeys.permissionLabelKey.g_localize(fallback: "Please grant access to photos and the camera.")
    
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    
    return label
  }
  
  func makeSettingButton() -> UIButton {
    let button = UIButton()
    button.setTitle(MediaPickerConfig.shared.translationKeys.goToSettingsKey.g_localize(fallback: "GO TO SETTINGS"), for: UIControl.State())
    button.backgroundColor = UIColor.init(red: 97/255, green: 69/255, blue: 146/255, alpha: 1)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 5
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
    
    return button
  }
  
  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(MediaPickerBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = UIColor(red: 109 / 255, green: 107 / 255, blue: 132 / 255, alpha: 1)
    return button
  }
  
  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = MediaPickerBundle.image("gallery_permission_view_camera")
    
    return view
  }
}

import UIKit

class PermissionView: UIView {
  lazy var closeButton: UIButton = self.makeCloseButton()
  lazy var permissionCenterView: PermissionCenterView = self.makePermissionCenterView()
    
  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.white
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  func setup() {
    [permissionCenterView, closeButton].forEach {
      addSubview($0)
    }
  
    closeButton.g_pin(on: .topMargin)
    closeButton.g_pin(on: .left)
    closeButton.g_pin(size: CGSize(width: 44, height: 44))
    
    permissionCenterView.g_pinEdges()
  }
  
  // MARK: - Controls
  
  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(MediaPickerBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: .normal)
    button.tintColor = UIColor(red: 109 / 255, green: 107 / 255, blue: 132 / 255, alpha: 1)
    return button
  }
  
  func makePermissionCenterView () -> PermissionCenterView {
    let view = PermissionCenterView(
      titleText: MediaPickerConfig.shared.translationKeys.permissionTitleLabelKey.g_localize(fallback: "No access"),
      labelText:  MediaPickerConfig.shared.translationKeys.missingPermissionDescriptionKey.g_localize(fallback: "Please grant access to photos and the camera."))

    return view
  }
}


class PermissionCenterView: UIView {
  lazy var imageView: UIImageView = self.makeImageView()
  lazy var titleLabel: UILabel = self.makeTitleLabel()
  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()
  
  let titleText: String
  let labelText: String
  
  init(titleText: String, labelText: String) {
    self.labelText = labelText
    self.titleText = titleText
    
    super.init(frame: .zero)
    
    backgroundColor = UIColor.white
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
  func setup() {
    [titleLabel, label, settingButton, imageView].forEach {
      addSubview($0)
    }
    
    titleLabel.g_pinCenter()
    label.g_pinHorizontally(padding: 50)
    label.g_pin(on: .top, view: titleLabel, on: .bottom, constant: 10)
    settingButton.g_pin(on: .top, view: label, on: .bottom, constant: 20)
    settingButton.g_pin(height: 32)
    settingButton.g_pin(on: .centerX)

    imageView.g_pin(on: .centerX)
    imageView.g_pin(on: .bottom, view: titleLabel, on: .top, constant: -44)
  }
  
  // MARK: - Controls
  
  func makeTitleLabel() -> UILabel {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    label.text = titleText
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }
  
  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 12, weight: .light)
    label.text = labelText
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
    return label
  }
  
  func makeSettingButton() -> UIButton {
    let button = UIButton()
    button.setTitle(MediaPickerConfig.shared.translationKeys.goToSettingsKey.g_localize(fallback: "Go to settings"), for: UIControl.State())
    button.backgroundColor = UIColor.init(red: 97/255, green: 69/255, blue: 146/255, alpha: 1)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
    button.setTitleColor(.white, for: .normal)
    button.layer.cornerRadius = 5
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    button.addTarget(self, action: #selector(settingButtonTouched(_:)), for: .touchUpInside)
    
    return button
  }
  
  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = MediaPickerBundle.image("Lock")
    
    return view
  }
  
  @objc func settingButtonTouched(_ button: UIButton) {
    DispatchQueue.main.async {
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
      }
    }
  }
}

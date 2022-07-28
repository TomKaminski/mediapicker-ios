class BaseTopView {
  func makeBackButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setImage(MediaPickerBundle.image("Back"), for: UIControl.State())
    button.addTarget(self, action: #selector(onBackButtonTap), for: .touchUpInside)
    return button
  }
  
  @objc internal func onBackButtonTap() {
    EventHub.shared.close?()
  }
}

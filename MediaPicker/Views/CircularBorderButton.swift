class CircularBorderButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.2)
    self.layer.borderColor = UIColor.white.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 20
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

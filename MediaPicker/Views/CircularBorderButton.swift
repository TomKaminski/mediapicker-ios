class CircularBorderButton: UIButton {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.53)
    self.layer.borderColor = MediaPickerConfig.instance.cartButton.textColor.cgColor
    self.layer.borderWidth = 1
    self.layer.cornerRadius = 20
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class FilenameInputView: UITextField {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.backgroundColor = UIColor.clear
    self.textColor = .gray
    self.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    self.borderStyle = .none
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

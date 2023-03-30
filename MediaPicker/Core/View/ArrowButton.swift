import UIKit

class ArrowButton: UIButton {
  lazy var label: UILabel = self.makeLabel()
  lazy var arrow: UIImageView = self.makeArrow()
  
  let padding: CGFloat = 10
  let arrowSizeH: CGFloat = 8
  let arrowSizeW: CGFloat = 12

  init() {
    super.init(frame: CGRect.zero)
    
    addSubview(label)
    addSubview(arrow)
  }
    
  override func layoutSubviews() {
    super.layoutSubviews()
    
    label.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    
    arrow.frame.size = CGSize(width: arrowSizeW, height: arrowSizeH)
    arrow.center = CGPoint(x: label.frame.maxX + padding, y: bounds.size.height / 2)
  }
  
  override var intrinsicContentSize : CGSize {
    let size = super.intrinsicContentSize
    label.sizeToFit()
    
    return CGSize(width: label.frame.size.width + arrowSizeW*2 + padding,
                  height: size.height)
  }
    
  func updateText(_ text: String) {
    label.text = text
    arrow.alpha = text.isEmpty ? 0 : 1
    invalidateIntrinsicContentSize()
  }
  
  func toggle(_ expanding: Bool) {
    let transform = expanding
      ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
    
    UIView.animate(withDuration: 0.25, animations: {
      self.arrow.transform = transform
    })
  }
    
  private func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = .white
    label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    label.textAlignment = .center
    
    return label
  }
  
  private func makeArrow() -> UIImageView {
    let arrow = UIImageView()
    arrow.image = MediaPickerBundle.image("arrowDownIcon")?.withRenderingMode(.alwaysTemplate)
    arrow.tintColor = .white
    arrow.alpha = 0
    
    return arrow
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
  
  var colorView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    colorView = UIView()
    self.contentView.addSubview(colorView)
    
    Constraint.on(constraints: [
      colorView.widthAnchor.constraint(equalToConstant: 20),
      colorView.heightAnchor.constraint(equalToConstant: 20),
      colorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
      colorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
    ])
    
    colorView.layer.cornerRadius = 10
    colorView.clipsToBounds = true
    colorView.layer.borderWidth = 1.0
    colorView.layer.borderColor = UIColor.white.cgColor
  }
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        let previouTransform = colorView.transform
        UIView.animate(withDuration: 0.2, animations: {
          self.colorView.transform = self.colorView.transform.scaledBy(x: 1.3, y: 1.3)
        }, completion: { _ in
          UIView.animate(withDuration: 0.2) {
            self.colorView.transform = previouTransform
          }
        })
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

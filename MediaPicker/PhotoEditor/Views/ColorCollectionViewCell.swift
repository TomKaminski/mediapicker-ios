import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
  var colorView: UIView!
  
  override init(frame: CGRect) {
    super.init(frame: .zero)
    
    colorView = UIView()
    colorView.translatesAutoresizingMaskIntoConstraints = false
    colorView.layer.cornerRadius = 15
    colorView.clipsToBounds = false
    colorView.layer.borderWidth = 2
    
    self.contentView.addSubview(colorView)
    
    colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
    colorView.heightAnchor.constraint(equalToConstant: 30).isActive = true
    colorView.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor).isActive = true
    colorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor).isActive = true
  }
  
  override var isSelected: Bool {
    didSet {
      if isSelected {
        colorView.layer.borderColor = UIColor.white.cgColor
      } else {
        colorView.layer.borderColor = UIColor.clear.cgColor
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

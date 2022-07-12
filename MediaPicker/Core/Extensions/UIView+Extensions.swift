import UIKit

extension UIView {
  
  func addShadow() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 1
  }
  
  func addRoundBorder() {
    layer.cornerRadius = 7
    clipsToBounds = true
  }
  
  func quickFade(visible: Bool = true) {
    UIView.animate(withDuration: 0.1, animations: {
      self.alpha = visible ? 1 : 0
    })
  }
  
  func fade(visible: Bool) {
    UIView.animate(withDuration: 0.25, animations: {
      self.alpha = visible ? 1 : 0
    })
  }
}

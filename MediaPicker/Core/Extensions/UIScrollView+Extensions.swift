import UIKit

extension UIScrollView {
  
  func scrollToTop() {
    setContentOffset(CGPoint.zero, animated: false)
  }
  
  func updateBottomInset(_ value: CGFloat) {
    var inset = contentInset
    inset.bottom = value
    
    contentInset = inset
    scrollIndicatorInsets = inset
  }
}

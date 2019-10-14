import UIKit

extension UIView {
  func toImage() -> UIImage {
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
    let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return snapshotImageFromMyView!
  }
}

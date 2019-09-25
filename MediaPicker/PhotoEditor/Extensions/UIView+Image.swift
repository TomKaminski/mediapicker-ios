import UIKit

extension UIView {
  func toImage() -> UIImage {
    print(self.bounds.size)
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
    self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
    let snapshotImageFromMyView = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return snapshotImageFromMyView!
  }
}

import UIKit

open class MediaPickerBundle {
  static public func image(_ named: String) -> UIImage? {
    let bundle = Foundation.Bundle(for: MediaPickerBundle.self)
    return UIImage(named: "MediaPicker.bundle/\(named)", in: bundle, compatibleWith: nil)
  }
}

import UIKit

class TopView: UIView {
  var state: MediaToolbarState = .Camera
  var activeTab: GalleryTab = .libraryTab {
    didSet {
      setupForActiveTab()
    }
  }
  
  required init() {
    super.init(frame: .zero)
    self.backgroundColor = MediaPickerConfig.instance.colors.black.withAlphaComponent(0.2)
    setup()
  }
  
  func setup() {}
  func setupForActiveTab() {}
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension PagesController: PageIndicatorDelegate {
  fileprivate func executePageSelect(index: Int) {
    self.pageIndicator.select(index: index)
    self.scrollTo(index: index, animated: false)
    self.updateAndNotify(index)
  }

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    guard index != selectedIndex else {
      return
    }
    
    if checkPermissionForPage(index: index) {
      self.executePageSelect(index: index)
    } else {
      let alertController = UIAlertController(title: nil, message: MediaPickerConfig.instance.translationKeys.missingPermissionKey.g_localize(fallback: "You do not have permission. Do you want to go to settings?"), preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.goToSettingsKey.g_localize(fallback: "Go to Settings"), style: .default, handler: { _ in
        DispatchQueue.main.async {
          if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
          }
        }
      }))
      alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel"), style: .cancel, handler: nil))
     self.present(alertController, animated: true, completion: nil)
    }
  }
  
  internal func checkPermissionForPage(index: Int) -> Bool {
    switch index {
    case 0:
      return Permission.Photos.status == .authorized || Permission.Photos.status == .restricted
    case 1:
      return Permission.Camera.status == .authorized
    case 2:
      return Permission.Microphone.status == .authorized
    default:
      return false
    }
  }
}

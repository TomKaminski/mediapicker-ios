extension PagesController: PageIndicatorDelegate {
  fileprivate func executePageSelect(index: Int) {
    pageIndicator.select(index: index)
    scrollTo(index: index, animated: false)
    updateAndNotify(index)
  }

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    guard index != selectedIndex else {
      return
    }
    
    if checkPermissionForPage(index: index) {
      executePageSelect(index: index)
    } else {
      let title = ""
      let message = MediaPickerConfig.shared.translationKeys.missingPermissionKey.g_localize(fallback: "You do not have permission. Do you want to go to settings?")
      let goToSettingsText = MediaPickerConfig.shared.translationKeys.goToSettingsKey.g_localize(fallback: "Go to Settings")
      let cancelText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
      
      
      if let dialogBuilder = MediaPickerConfig.shared.dialogBuilder, let controller = dialogBuilder(title, message, [
        (goToSettingsText, "standard", {
          DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
          }
        }),
        (cancelText, "cancel", nil)
      ]) {
        self.present(controller, animated: true, completion: nil)
      } else {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: goToSettingsText, style: .default, handler: { _ in
          DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
              UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            }
          }
        }))
        alertController.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
      }
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

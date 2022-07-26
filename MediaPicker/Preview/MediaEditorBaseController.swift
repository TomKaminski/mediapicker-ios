public class MediaEditorBaseController: UIViewController {
  let saveButton = GalleryFloatingButton()
  
  var newlyTaken: Bool = true
  var customFileName: String?

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = MediaPickerConfig.shared.colors.black
    saveButton.imageView.image = MediaPickerConfig.shared.bottomView.saveIcon
    
    addSubviews()
    setupConstraints()
  }
  
  func addSubviews() {
    view.addSubview(saveButton)
  }
    
  func presentDiscardChangesAlert() {
    let title = MediaPickerConfig.shared.translationKeys.discardChangesKey.g_localize(fallback: "Discard changes")
    let message = MediaPickerConfig.shared.translationKeys.discardChangesDescriptionKey.g_localize(fallback: "Are you sure you want to discard changes?")
    let discardBtnText = MediaPickerConfig.shared.translationKeys.discardKey.g_localize(fallback: "Discard")
    let cancelBtnText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let dialogBuilder = MediaPickerConfig.shared.dialogBuilder, let controller = dialogBuilder(title, message, [
      (cancelBtnText, "cancel", nil),
      (discardBtnText, "delete", {
        self.dismiss(animated: true, completion: nil)
      })
    ]) {
      self.present(controller, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: discardBtnText, style: .destructive, handler: { _ in
        self.dismiss(animated: true, completion: nil)
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func onBackTap() {
    self.dismiss(animated: true, completion: nil)
  }
  
  internal func setupConstraints() {
    saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
    saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
  }
}

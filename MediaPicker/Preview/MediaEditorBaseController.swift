public class MediaEditorBaseController: UIViewController {
  public var customFileName: String? {
    didSet {
      onFilenameChanged()
    }
  }
  
  public weak var renameDelegate: MediaRenameControllerDelegate?

  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MediaPickerConfig.shared.colors.black
  }
  
  internal func onFilenameChanged() {}
  
  func presentRenameAlert(guid: String, baseFilename: String) {
    let renameText = MediaPickerConfig.shared.translationKeys.renameKey.g_localize(fallback: "Rename")
    let cancelText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let textDialogBuilder = MediaPickerConfig.shared.textDialogBuilder, let controller = textDialogBuilder(renameText, nil, customFileName, [
      (cancelText, "cancel", nil),
      (renameText, "standard", { inputValue in
        self.customFileName = inputValue ?? baseFilename
        self.renameDelegate?.renameMediaFile(guid: guid, newFileName: inputValue ?? baseFilename)
      })
    ]) {
      self.present(controller, animated: true)
    } else {
      let alertController = UIAlertController(title: renameText, message: nil, preferredStyle: .alert)
      
      alertController.addTextField { (textField) in
        textField.text = self.customFileName
      }
      
      alertController.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: renameText, style: .default, handler: { _ in
        let textField = alertController.textFields![0]
        let newFileName = textField.text?.isEmpty == false ? textField.text! : baseFilename
        self.customFileName = newFileName
        self.renameDelegate?.renameMediaFile(guid: guid, newFileName: newFileName)
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
}

public class MediaEditorBaseController: UIViewController {
  var customFileName: String? {
    didSet {
      onFilenameChanged()
    }
  }
  
  weak var renameDelegate: MediaRenameControllerDelegate?

  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MediaPickerConfig.shared.colors.black
  }
  
  internal func onFilenameChanged() {}
  
  func presentRenameAlert(guid: String, baseFilename: String) {
    let title = "Rename"
    let cancelText = "Cancel"
    let saveText = "Save"
    
    if let textDialogBuilder = MediaPickerConfig.shared.textDialogBuilder, let controller = textDialogBuilder(title, nil, customFileName, [
      (cancelText, "cancel", nil),
      (saveText, "standard", { inputValue in
        self.renameDelegate?.renameMediaFile(guid: guid, newFileName: inputValue ?? baseFilename)
      })
    ]) {
      self.present(controller, animated: true)
    } else {
      let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
      
      alertController.addTextField { (textField) in
        textField.text = self.customFileName
      }
      
      alertController.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: saveText, style: .default, handler: { _ in
        let textField = alertController.textFields![0]
        let newFileName = textField.text?.isEmpty == false ? textField.text! : baseFilename
        self.customFileName = newFileName
        self.renameDelegate?.renameMediaFile(guid: guid, newFileName: newFileName)
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
}

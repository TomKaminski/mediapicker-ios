protocol MediaEditorControllerDelegate: AnyObject {
  func onFileRename(guid: String, newFileName: String)
  func doneEditingPhoto(image: UIImage, customFileName: String, guid: String, editedSomething: Bool)
}

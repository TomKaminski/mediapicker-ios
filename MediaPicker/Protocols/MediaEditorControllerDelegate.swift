protocol PhotoEditorControllerDelegate: AnyObject {
  func editMediaFile(image: UIImage, customFileName: String, guid: String, editedSomething: Bool)
}

protocol MediaRenameControllerDelegate: AnyObject {
  func renameMediaFile(guid: String, newFileName: String)
}

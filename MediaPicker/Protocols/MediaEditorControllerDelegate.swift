public protocol PhotoEditorControllerDelegate: AnyObject {
  func editMediaFile(image: UIImage, fileName: String, guid: String, editedSomething: Bool)
}

public protocol MediaRenameControllerDelegate: AnyObject {
  func renameMediaFile(guid: String, newFileName: String)
}

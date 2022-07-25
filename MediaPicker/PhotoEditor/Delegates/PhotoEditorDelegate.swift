public protocol PhotoEditorDelegate {
  func doneEditing(image: UIImage, customFileName: String, selfCtrl: PhotoEditorController, editedSomething: Bool)
  func canceledEditing()
}

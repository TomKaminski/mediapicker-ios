public protocol MediaPickerControllerDelegate: AnyObject {
  func mediaPicker(_ controller: MediaPickerController, didSelectMedia media: [CartItemProtocol])
  func mediaPickerDidCancel(_ controller: MediaPickerController)
}

extension MediaPickerController: PreviewItemsControllerDelegate {
  func getItems() -> [String : CartItemProtocol] {
    return [:]
  }
  
  func removeItem(guid: String) {}
  
  func replaceItem(oldGuid: String, newItemGuid: String, newItem: CartItemProtocol) {}
}

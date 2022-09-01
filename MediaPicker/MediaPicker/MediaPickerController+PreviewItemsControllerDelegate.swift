extension MediaPickerController: PreviewItemsControllerDelegate {
  func getItems() -> [String : CartItemProtocol] {
    return cart.items
  }
  
  func removeItem(guid: String) {}
  
  func replaceItem(oldGuid: String, newItemGuid: String, newItem: CartItemProtocol) {}
}

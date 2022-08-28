protocol PreviewItemsControllerDelegate: AnyObject {
  func getItems() -> [String: CartItemProtocol]
  func removeItem(guid: String)
  func replaceItem(oldGuid: String, newItemGuid: String, newItem: CartItemProtocol)
}

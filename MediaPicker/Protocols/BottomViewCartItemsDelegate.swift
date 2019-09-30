protocol BottomViewCartItemsDelegate: AnyObject {
  var itemsInCart: Int { get }
  var cartItems: [String: CartItemProtocol] { get }
  
  func addUpdateCartItem(item: CartItemProtocol)
  func onItemRemove(guid: String)
  func onModalItemRemove(guid: String)
}

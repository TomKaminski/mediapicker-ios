protocol BottomViewDelegate: AnyObject {
  func shutterButtonTouched()
  func shutterButtonHeld()
  func shutterButtonReleased()
  
  var itemsInCart: Int { get }
  var cartItems: [String: CartItemProtocol] { get }
  
  func onSaveTapped(item: CartItemProtocol)
  func onItemRemove(guid: String)
  func onModalItemRemove(guid: String)
}

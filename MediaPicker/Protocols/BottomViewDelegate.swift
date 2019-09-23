protocol BottomViewDelegate: BottomViewCartItemsDelegate {
  func bottomView(_ changedStateTo: MediaToolbarState)
  func shutterButtonTouched()
  func shutterButtonHeld()
  func shutterButtonReleased()
}

protocol BottomViewCartItemsDelegate: AnyObject {
  var itemsInCart: Int { get }
  var cartItems: [String: CartItemProtocol] { get }
  
  func addUpdateCartItem(item: CartItemProtocol)
}

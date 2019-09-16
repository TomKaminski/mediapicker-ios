protocol BottomViewDelegate: AnyObject {
  var itemsInCart: Int { get }
  var cartItems: [String:CartItemProtocol] { get }
  
  func bottomView(_ changedStateTo: MediaToolbarState)
  func shutterButtonTouched()
  func shutterButtonHeld()
  func shutterButtonReleased()
}

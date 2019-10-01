extension CameraController: CartDelegate {
  func cart(_ cart: Cart, didAdd video: Video) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count, false)
  }
  
  func cart(_ cart: Cart, didAdd audio: Audio) {

  }
  
  func cart(_ cart: Cart, didAdd image: Image) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count, false)
  }
  
  func cart(_ cart: Cart, didRemove image: Image) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count, pagesController.cartButton.cartOpened)
  }
  
  func cart(_ cart: Cart, didRemove audio: Audio) {

  }
  
  func cart(_ cart: Cart, didRemove video: Video) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count, pagesController.cartButton.cartOpened)
  }
  
  func cartDidReload(_ cart: Cart) {
    
  }
  
  var basicBottomViewState: MediaToolbarState {
    return .Camera
  }
}

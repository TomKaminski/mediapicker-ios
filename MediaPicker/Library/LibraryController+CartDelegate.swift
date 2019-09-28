extension LibraryController: CartDelegate {
  var basicBottomViewState: MediaToolbarState {
    return .Library
  }
  
  func cart(_ cart: Cart, didAdd video: Video) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
  }

  func cart(_ cart: Cart, didAdd audio: Audio) {
    //Nothing here
  }

  func cart(_ cart: Cart, didAdd image: Image) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
  }

  func cart(_ cart: Cart, didRemove image: Image) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
    configureFrameViews()
  }

  func cart(_ cart: Cart, didRemove audio: Audio) {
    //Nothing here
  }

  func cart(_ cart: Cart, didRemove video: Video) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
    configureFrameViews()
  }

  func cartDidReload(_ cart: Cart) {

  }
}

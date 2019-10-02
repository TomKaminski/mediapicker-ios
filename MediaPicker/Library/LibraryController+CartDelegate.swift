extension LibraryController: CartDelegate {
  var basicBottomViewState: MediaToolbarState {
    return .Library
  }
  
  func cart(_ cart: Cart, didAdd video: Video) {
  }

  func cart(_ cart: Cart, didAdd audio: Audio) {
    //Nothing here
  }

  func cart(_ cart: Cart, didAdd image: Image) {
  }

  func cart(_ cart: Cart, didRemove image: Image) {
    configureFrameViews()
  }

  func cart(_ cart: Cart, didRemove audio: Audio) {
    //Nothing here
  }

  func cart(_ cart: Cart, didRemove video: Video) {
    configureFrameViews()
  }

  func cartDidReload(_ cart: Cart) {

  }
}

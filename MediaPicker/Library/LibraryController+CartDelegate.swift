extension LibraryController: CartDelegate {
  func cart(_ cart: Cart, didRemove image: Image) {
    configureFrameViews()
  }

  func cart(_ cart: Cart, didRemove video: Video) {
    configureFrameViews()
  }
}

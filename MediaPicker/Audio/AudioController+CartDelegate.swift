extension AudioController: CartDelegate {
  func cart(_ cart: Cart, didRemove image: Image) {}
  func cart(_ cart: Cart, didRemove video: Video) {}
}

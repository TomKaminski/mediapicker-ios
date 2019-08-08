public protocol CartDelegate: AnyObject {
  func cart(_ cart: Cart, didAdd video: Video)
  func cart(_ cart: Cart, didAdd audio: Audio)
  func cart(_ cart: Cart, didAdd image: Image)
  func cart(_ cart: Cart, didRemove image: Image)
  func cart(_ cart: Cart, didRemove audio: Audio)
  func cart(_ cart: Cart, didRemove video: Video)
  func cartDidReload(_ cart: Cart)
}

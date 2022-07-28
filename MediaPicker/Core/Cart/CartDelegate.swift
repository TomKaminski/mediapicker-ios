public protocol CartDelegate: AnyObject {
  func cart(_ cart: Cart, didRemove image: Image)
  func cart(_ cart: Cart, didRemove video: Video)
}

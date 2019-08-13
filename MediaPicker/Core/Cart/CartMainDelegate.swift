public protocol CartMainDelegate : AnyObject {
  func itemAdded(item: CartItemProtocol)
  func itemRemoved(item: CartItemProtocol)
}

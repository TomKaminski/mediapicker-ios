
public class Cart {

  public var items: [CartItemProtocol] = []

  var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

  // MARK: - Initialization

  init() {

  }

  // MARK: - Delegate

  public func add(delegate: CartDelegate) {
    delegates.add(delegate)
  }

  public func add(_ item: CartItemProtocol) {
    items.append(item)

    for case let delegate as CartDelegate in delegates.allObjects {
      switch item.type {

      case .Audio:
        delegate.cart(self, didAdd: item as! Audio)
      case .Video:
        delegate.cart(self, didAdd: item as! Video)
      case .Image:
        delegate.cart(self, didAdd: item as! Image)
      }
    }
  }

  public func remove(_ itemToRemove: CartItemProtocol) {
    guard let index = items.firstIndex(where: { (cartItem) -> Bool in
      return cartItem.guid == itemToRemove.guid
    }) else { return }

    items.remove(at: index)

    for case let delegate as CartDelegate in delegates.allObjects {
      switch itemToRemove.type {

      case .Audio:
        delegate.cart(self, didRemove: itemToRemove as! Audio)
      case .Video:
        delegate.cart(self, didRemove: itemToRemove as! Video)
      case .Image:
        delegate.cart(self, didRemove: itemToRemove as! Image)
      }
    }
  }
}

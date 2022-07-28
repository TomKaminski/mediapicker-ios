public class Cart {

  public var items: [String:CartItemProtocol] = [:]
  
  public var itemsInArray: [CartItemProtocol] {
    return Array(items.values.sorted(by: { item1, item2 in
      return item1.dateAdded < item2.dateAdded
    }))
  }

  var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
  weak var cartMainDelegate: CartMainDelegate?
  
  // MARK: - Initialization

  init() {}

  // MARK: - Delegate

  public func add(delegate: CartDelegate) {
    delegates.add(delegate)
  }

  public func add(_ item: CartItemProtocol) {
    if let maxItems = MediaPickerConfig.shared.cart.maxItems, maxItems == items.count {
      return
    }
    
    items.updateValue(item, forKey: item.guid)
    cartMainDelegate?.itemAdded(item: item)
  }

  public func remove(_ itemToRemove: CartItemProtocol) {
    items.removeValue(forKey: itemToRemove.guid)
    cartMainDelegate?.itemRemoved(item: itemToRemove)
    processRemoveEvent(itemToRemove)
  }
  
  public func remove(guidToRemove: String) {
    if let itemToRemove = items[guidToRemove] {
      self.remove(itemToRemove)
    }
  }
  
  public func getItem(by guid: String) -> CartItemProtocol? {
    return items[guid]
  }
  
  fileprivate func processRemoveEvent(_ itemToRemove: CartItemProtocol) {
    for case let delegate as CartDelegate in delegates.allObjects {
      switch itemToRemove.type {
      case .Audio:
        break
      case .Video:
        delegate.cart(self, didRemove: itemToRemove as! Video)
      case .Image:
        delegate.cart(self, didRemove: itemToRemove as! Image)
      }
    }
  }
}

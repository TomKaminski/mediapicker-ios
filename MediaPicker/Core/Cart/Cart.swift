public class Cart {

  public var items: [String:CartItemProtocol] = [:]

  var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
  weak var cartMainDelegate: CartMainDelegate?
  
  // MARK: - Initialization

  init() {}

  // MARK: - Delegate

  public func add(delegate: CartDelegate) {
    delegates.add(delegate)
  }

  public func add(_ item: CartItemProtocol) {
    if let maxItems = MediaPickerConfig.instance.bottomView.cart.maxItems, maxItems == items.count {
      return
    }
    
    items.updateValue(item, forKey: item.guid)
    cartMainDelegate?.itemAdded(item: item)

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
        delegate.cart(self, didRemove: itemToRemove as! Audio)
      case .Video:
        delegate.cart(self, didRemove: itemToRemove as! Video)
      case .Image:
        delegate.cart(self, didRemove: itemToRemove as! Image)
      }
    }
  }
}

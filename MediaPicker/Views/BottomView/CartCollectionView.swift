protocol CartCollectionViewDelegate: AnyObject {
  func reselectItem()
  func onItemDelete(guid: String)
}

protocol BottomViewCartDelegate: AnyObject {
  func closeCartView()
  func onItemDelete(guid: String)
}

class CartCollectionView: GenericHorizontalScrollView<CartCollectionItemView>, CartCollectionViewDelegate {
  weak var bottomViewCartDelegate: BottomViewCartDelegate?
  
  var views = [CartCollectionItemView]()
  
  init(frame: CGRect, cartItems: [String: CartItemProtocol]) {
    super.init(frame: frame)
    
    self.buildScrollView(cartItems: cartItems)
    self.scrollToEnd()
  }
  
  func onItemDelete(guid: String) {
    self.bottomViewCartDelegate?.onItemDelete(guid: guid)
  }
  
  public func addItem(item: CartItemProtocol) {
    let itemView = item.cartView

    if let sameItemIndex = self.views.firstIndex(where: { (collectionItem) -> Bool in
      return item.guid == collectionItem.guid
    }) {
      self.views[sameItemIndex] = itemView
      _ = self.removeAllItems()
      self.addItems(self.views)
    } else {
      self.views.append(itemView)
      self.addItem(itemView)
    }
  }
  
  public func removeItem(item: CartItemProtocol) {
    if let itemIndex = self.views.firstIndex(where: { (itemInScrollView) -> Bool in
      return itemInScrollView.guid == item.guid
    }) {
      _ = self.removeItemAtIndex(itemIndex)
      _ = self.views.remove(at: itemIndex)
    }
    
    if self.views.isEmpty {
      self.bottomViewCartDelegate?.closeCartView()
    }
  }
  
  public func removeItem(by guid: String) {
    if let itemIndex = self.views.firstIndex(where: { (itemInScrollView) -> Bool in
      return itemInScrollView.guid == guid
    }) {
      _ = self.removeItemAtIndex(itemIndex)
      _ = self.views.remove(at: itemIndex)
    }
    
    if self.views.isEmpty {
      self.bottomViewCartDelegate?.closeCartView()
    }
  }
  
  public func reselectItem() {
    self.views.forEach { (view) in
      view.selected = view.guid == MediaPickerConfig.instance.bottomView.cart.selectedGuid
    }
  }
  
  private func buildScrollView(cartItems: [String: CartItemProtocol]) {
    _ = self.removeAllItems()
    self.views = cartItems.sorted(by: { $0.value.dateAdded < $1.value.dateAdded }).compactMap { (cartItem) -> CartCollectionItemView in
      let view = cartItem.value.cartView
      view.delegate = self
      view.selected = view.guid == MediaPickerConfig.instance.bottomView.cart.selectedGuid
      return view
    }
    self.addItems(self.views)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

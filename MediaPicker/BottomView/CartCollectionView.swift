class CartCollectionView: GenericHorizontalScrollView<CartCollectionItemView> {
  var views = [CartCollectionItemView]()
  
  init(frame: CGRect, cartItems: [String: CartItemProtocol]) {
    super.init(frame: frame)
    
    self.buildScrollView(cartItems: cartItems)
  }
  
  public func addItem(item: CartItemProtocol) {
    let itemView = item.cartView
    self.views.append(itemView)
    self.addItem(itemView)
  }
  
  public func removeItem(item: CartItemProtocol) {
    if let itemIndex = self.views.firstIndex(where: { (itemInScrollView) -> Bool in
      return itemInScrollView.guid == item.guid
    }) {
      _ = self.removeItemAtIndex(itemIndex)
      _ = self.views.remove(at: itemIndex)
    }
  }
  
  public func removeItem(by guid: String) {
    if let itemIndex = self.views.firstIndex(where: { (itemInScrollView) -> Bool in
      return itemInScrollView.guid == guid
    }) {
      _ = self.removeItemAtIndex(itemIndex)
      _ = self.views.remove(at: itemIndex)
    }
  }
  
  private func buildScrollView(cartItems: [String: CartItemProtocol]) {
    _ = self.removeAllItems()
    self.views = cartItems.compactMap { (cartItem) -> CartCollectionItemView in
      return cartItem.value.cartView
    }
    self.addItems(self.views)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

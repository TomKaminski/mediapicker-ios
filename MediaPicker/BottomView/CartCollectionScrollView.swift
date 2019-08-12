class CartCollectionScrollView: GenericHorizontalScrollView<CartCollectionItemView> {
  var views = [CartCollectionItemView]()
  
  init(frame: CGRect, cartItems: [CartItemProtocol]) {
    super.init(frame: frame)
    
    self.buildScrollView(cartItems: cartItems)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func buildScrollView(cartItems: [CartItemProtocol]) {
    _ = self.removeAllItems()
    self.views = cartItems.compactMap { (cartItem) -> CartCollectionItemView in
      return cartItem.cartView
    }
    self.addItems(self.views)
  }
}

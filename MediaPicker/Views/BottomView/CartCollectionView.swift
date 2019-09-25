protocol CartCollectionViewDelegate: class {
  func reselectItem()
}

protocol BottomViewCartDelegate: class {
  func closeCartView()
}

class CartCollectionView: GenericHorizontalScrollView<CartCollectionItemView>, CartCollectionViewDelegate {
  
  weak var bottomViewCartDelegate: BottomViewCartDelegate?
  
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
      view.selected = view.guid == Config.BottomView.Cart.selectedGuid
    }
  }
  
  private func buildScrollView(cartItems: [String: CartItemProtocol]) {
    _ = self.removeAllItems()
    self.views = cartItems.compactMap { (cartItem) -> CartCollectionItemView in
      let view = cartItem.value.cartView
      view.delegate = self
      view.selected = view.guid == Config.BottomView.Cart.selectedGuid
      return view
    }
    self.addItems(self.views)
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

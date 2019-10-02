extension MediaPickerController: CartMainDelegate {
  public func itemAdded(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartView?.addItem(item: item)
    //self.pagesController?.hideCart()
    self.pagesController?.cartButton.updateCartItemsLabel(cart.items.count, false)
  }
  
  public func itemRemoved(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartView?.removeItem(item: item)
    self.pagesController?.cartButton.updateCartItemsLabel(cart.items.count, false)
    
    if self.cart.items.isEmpty {
      self.pagesController?.hideCart()
    }
  }
}

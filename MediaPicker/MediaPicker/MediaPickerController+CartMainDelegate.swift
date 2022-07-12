extension MediaPickerController: CartMainDelegate {
  public func itemAdded(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartButton.isHidden = self.pagesController?.cartItems.count == 0
    self.pagesController?.bottomView.saveButton.isHidden = self.pagesController?.cartItems.count == 0
    self.pagesController?.bottomView.cartView?.addItem(item: item)
    self.pagesController?.bottomView.cartButton.reload(cart.itemsInArray, added: true)
    self.pagesController?.bottomView.cartButton.stopLoading()
  }
  
  public func itemRemoved(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartButton.isHidden = self.pagesController?.cartItems.count == 0
    self.pagesController?.bottomView.saveButton.isHidden = self.pagesController?.cartItems.count == 0
    self.pagesController?.bottomView.cartView?.removeItem(item: item)
    self.pagesController?.bottomView.cartButton.reload(cart.itemsInArray)

    if self.cart.items.isEmpty {
      self.pagesController?.hideCart()
    }
    
    self.pagesController?.bottomView.cartButton.stopLoading()
  }
}

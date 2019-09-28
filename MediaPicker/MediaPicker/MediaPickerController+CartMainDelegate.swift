extension MediaPickerController: CartMainDelegate {
  public func itemAdded(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartView?.addItem(item: item)
  }
  
  public func itemRemoved(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartView?.removeItem(item: item)
  }
}

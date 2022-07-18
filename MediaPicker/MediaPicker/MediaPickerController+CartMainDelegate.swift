extension MediaPickerController: CartMainDelegate {
  public func itemAdded(item: CartItemProtocol) {
    guard let pagesController = pagesController else {
      return
    }
    
    let cartEmpty = pagesController.cartItems.count == 0
    pagesController.bottomView.cartButton.isHidden = cartEmpty
    pagesController.bottomView.saveButton.isHidden = cartEmpty
    pagesController.bottomView.cartButton.reload(cart.itemsInArray, added: true)
    pagesController.bottomView.cartButton.stopLoading()
    pagesController.cartView?.addItem(item: item)
  }
  
  public func itemRemoved(item: CartItemProtocol) {
    guard let pagesController = pagesController else {
      return
    }
    
    let cartEmpty = pagesController.cartItems.count == 0
    pagesController.bottomView.cartButton.isHidden = cartEmpty
    pagesController.bottomView.saveButton.isHidden = cartEmpty
    pagesController.bottomView.cartButton.reload(cart.itemsInArray)
    pagesController.bottomView.cartButton.stopLoading()

    pagesController.cartView?.removeItem(item: item)

    if cart.items.isEmpty {
      pagesController.hideCart()
    }
  }
}

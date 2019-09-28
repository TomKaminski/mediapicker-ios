extension PagesController: BottomViewDelegate {
  func addUpdateCartItem(item: CartItemProtocol) {
    if self.mediaPickerController.cart.items[item.guid] != nil {
      self.mediaPickerController.cart.items.updateValue(item, forKey: item.guid)
    } else {
      self.mediaPickerController.cart.items[item.guid] = item
    }
  }
  
  func shutterButtonHeld() {
    (self.activeController as? CameraPageAware)?.shutterButtonHeld()
    self.cartButton.isHidden = true
  }
  
  func shutterButtonReleased() {
    (self.activeController as? CameraPageAware)?.shutterButtonReleased()
    self.cartButton.isHidden = false
  }
  
  func shutterButtonTouched() {
    (self.activeController as? CameraPageAware)?.shutterButtonTapped()
  }
  
  var cartItems: [String: CartItemProtocol] {
    return self.mediaPickerController.cart.items
  }
  
  var mediaPickerController: MediaPickerController {
    return self.parent as! MediaPickerController
  }
  
  var itemsInCart: Int {
    return self.mediaPickerController.cart.items.count
  }
}

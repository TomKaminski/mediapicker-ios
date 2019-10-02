extension PagesController: BottomViewDelegate {
  func onModalItemRemove(guid: String) {
    self.mediaPickerController.cart.remove(guidToRemove: guid)
  }
  
  func onItemRemove(guid: String) {
     let alertController = UIAlertController(title: "Discard element", message: "Are you sure you want to discard current element?", preferredStyle: .alert)
     alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
        self.mediaPickerController.cart.remove(guidToRemove: guid)
     }))
     alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.mediaPickerController.present(alertController, animated: true, completion: nil)
  }
  
  func addUpdateCartItem(item: CartItemProtocol) {
    if self.mediaPickerController.cart.items[item.guid] != nil {
      self.mediaPickerController.cart.items.updateValue(item, forKey: item.guid)
    } else {
      self.mediaPickerController.cart.items[item.guid] = item
    }
    
    mediaPickerController.itemAdded(item: item)
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

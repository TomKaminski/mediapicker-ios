extension PagesController: BottomViewDelegate {
  func onModalItemRemove(guid: String) {
    mediaPickerController.cart.remove(guidToRemove: guid)
  }
  
  func onItemRemove(guid: String) {
     let alertController = UIAlertController(title: MediaPickerConfig.instance.translationKeys.deleteElementKey.g_localize(fallback: "Delete element"), message: MediaPickerConfig.instance.translationKeys.deleteElementDescriptionKey.g_localize(fallback: "Are you sure you want to delete?"), preferredStyle: .alert)
     alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.deleteKey.g_localize(fallback: "Delete"), style: .destructive, handler: { _ in
        self.mediaPickerController.cart.remove(guidToRemove: guid)
     }))
     alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel"), style: .cancel, handler: nil))
    self.mediaPickerController.present(alertController, animated: true, completion: nil)
  }
  
  func addUpdateCartItem(item: CartItemProtocol) {
    if mediaPickerController.cart.items[item.guid] != nil {
      mediaPickerController.cart.items.updateValue(item, forKey: item.guid)
    } else {
      mediaPickerController.cart.items[item.guid] = item
    }
    
    mediaPickerController.itemAdded(item: item)
  }
  
  func shutterButtonHeld() {
    (activeController as? CameraPageAware)?.shutterButtonHeld()
    bottomView.cartButton.isHidden = true
    bottomView.saveButton.isHidden = true
  }
  
  func shutterButtonReleased() {
    (activeController as? CameraPageAware)?.shutterButtonReleased()
    bottomView.cartButton.isHidden = false
    bottomView.saveButton.isHidden = false
  }
  
  func shutterButtonTouched() {
    (activeController as? CameraPageAware)?.shutterButtonTapped()
  }
  
  var cartItems: [String: CartItemProtocol] {
    return mediaPickerController.cart.items
  }
  
  var mediaPickerController: MediaPickerController {
    return parent as! MediaPickerController
  }
  
  var itemsInCart: Int {
    return mediaPickerController.cart.items.count
  }
}

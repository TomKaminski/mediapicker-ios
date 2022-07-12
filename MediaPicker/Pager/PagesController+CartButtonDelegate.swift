extension PagesController: CartButtonDelegate {
  func cartButtonTapped() {
    cartOpened = !cartOpened
    cartView.quickFade(visible: cartOpened)
  }
  
  func hideCart() {
    cartOpened = false
    cartView.quickFade(visible: false)
  }
}

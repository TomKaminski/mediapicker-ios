extension PagesController: CartButtonDelegate {
  func cartButtonTapped() {
    cartOpened = !cartOpened
    if cartOpened {
      //TODO: Animate show cart
    } else {
      //TODO: Aniamte hide cart
    }
    
    self.bottomView.setup()
  }
  
  func hideCart() {
    cartOpened = false
    //TODO: Aniamte hide cart
  }
}

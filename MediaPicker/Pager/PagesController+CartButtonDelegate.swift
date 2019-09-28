extension PagesController: CartButtonDelegate {
  func cartButtonTapped() {
    
    self.cartButton.cartOpened = !self.cartButton.cartOpened
    if self.cartButton.cartOpened {
      self.changeBottomViewState(.CartExpanded)
    } else {
      if let controller = controllers[selectedIndex] as? CartDelegate {
        self.changeBottomViewState(controller.basicBottomViewState);
      }
    }
    
    self.bottomView.setup()
  }
}

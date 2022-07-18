extension PagesController: CartButtonDelegate {
  func cartButtonTapped() {
    cartOpened = !cartOpened
    if (cartOpened) {
      addCartCollectionView()
      cartView?.quickFade(visible: true)
    } else {
      cartView?.quickFade(visible: false)
      cartView?.removeFromSuperview()
      cartView = nil
    }
  }
  
  func hideCart() {
    cartOpened = false
    cartView?.quickFade(visible: false)
    cartView?.removeFromSuperview()
    cartView = nil
  }
  
  internal func addCartCollectionView() {
    let cartView = CartCollectionView(frame: .zero, cartItems: self.cartItems)
    cartView.bottomViewCartDelegate = self
    cartView.backgroundColor = MediaPickerConfig.instance.colors.black.withAlphaComponent(0.2)
    cartView.alpha = 0
    
    view.addSubview(cartView)

    cartView.translatesAutoresizingMaskIntoConstraints = false
    cartView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    cartView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    cartView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.bottomView.height).isActive = true
    cartView.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
    
    self.cartView = cartView
  }
}

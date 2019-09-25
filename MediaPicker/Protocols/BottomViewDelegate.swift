protocol BottomViewDelegate: BottomViewCartItemsDelegate {
  func bottomView(_ changedStateTo: MediaToolbarState)
  func shutterButtonTouched()
  func shutterButtonHeld()
  func shutterButtonReleased()
}

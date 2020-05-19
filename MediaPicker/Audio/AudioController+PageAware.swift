extension AudioController: PageAware {
  func switchedToState(state: MediaToolbarState) { }
  
  func pageDidShow() {
    self.pagesController.mediaPickerController.rotateButtons()
  }
  
  func pageDidHide() {}

  var initialBottomViewState: MediaToolbarState {
    return .Audio
  }
  
  func setupForOrientation(angle: CGFloat) {
    
  }
}

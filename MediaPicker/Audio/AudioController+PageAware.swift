extension AudioController: PageAware {
  func switchedToState(state: MediaToolbarState) { }
  
  func pageDidShow() {
    pagesController?.mediaPickerController?.rotateButtons()
  }
  
  func pageDidHide() {
    clearDataFunc()
    EventHub.shared.changeMediaPickerState?(.Audio)
  }

  var initialBottomViewState: MediaToolbarState {
    return .Audio
  }
  
  func setupForOrientation(angle: CGFloat) {
    
  }
}

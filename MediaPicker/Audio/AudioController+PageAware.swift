extension AudioController: PageAware {
  func switchedToState(state: MediaToolbarState) { }
  
  func pageDidShow() {}
  
  func pageDidHide() {}

  var initialBottomViewState: MediaToolbarState {
    return .Audio
  }
}

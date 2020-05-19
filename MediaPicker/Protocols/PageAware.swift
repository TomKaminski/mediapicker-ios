protocol PageAware: AnyObject {
  func pageDidShow()
  func pageDidHide()
  
  var initialBottomViewState: MediaToolbarState { get }
  
  func switchedToState(state: MediaToolbarState)
  func setupForOrientation(angle: CGFloat)
}

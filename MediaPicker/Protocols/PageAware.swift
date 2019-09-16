protocol PageAware: AnyObject {
  func pageDidShow()
  func pageDidHide()
  
  var initialBottomViewState: MediaToolbarState { get }
  
  func switchedToState(state: MediaToolbarState)
}

protocol CameraPageAware: PageAware {
  func shutterButtonTapped()
  func shutterButtonHeld()
  func shutterButtonReleased()
}

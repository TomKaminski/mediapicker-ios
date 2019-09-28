extension CameraController: CameraPageAware {
  func shutterButtonHeld() {
    Config.Camera.recordMode = .video
    self.cameraView.rotateButton.isHidden = true
    self.cameraView.flashButton.isHidden = true
    
    self.cameraView.showTimer()
    self.cameraMan.startVideoRecord(location: nil, startCompletion: { result in })
  }
  
  func shutterButtonReleased() {
    self.cameraView.rotateButton.isHidden = false
    self.cameraView.flashButton.isHidden = false
    self.cameraView.videoRecordingTimer?.invalidate()
    self.cameraView.elapsedVideoRecordingTimeLabel.isHidden = true
    self.cameraMan.stopVideoRecording()
  }
  
  func shutterButtonTapped() {
    guard let previewLayer = cameraView.previewLayer else { return }

    self.pagesController.bottomView.shutterButton?.isEnabled = false
    UIView.animate(withDuration: 0.1, animations: {
      self.cameraView.shutterOverlayView.alpha = 1
    }, completion: { _ in
      UIView.animate(withDuration: 0.1, animations: {
        self.cameraView.shutterOverlayView.alpha = 0
      })
    })
    
    cameraMan.takePhoto(previewLayer, location: nil)
  }
  
  func switchedToState(state: MediaToolbarState) { }
  
  func pageDidHide() {
    self.cameraView.rotateButton.isHidden = false
    self.cameraView.flashButton.isHidden = false
    self.pagesController.cartButton.isHidden = self.pagesController.cartItems.count == 0
  }
  
  func pageDidShow() {
    once.run {
      cameraMan.setup()
    }
  }

  var initialBottomViewState: MediaToolbarState {
    return .Camera
  }
  
  var pagesController: PagesController {
    return self.parent as! PagesController
  }
}

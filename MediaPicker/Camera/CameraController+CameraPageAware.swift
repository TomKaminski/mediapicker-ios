extension CameraController: CameraPageAware {
  func shutterButtonHeld() {
    MediaPickerConfig.instance.camera.recordMode = .video
    self.cameraView.rotateButton.isHidden = true
    self.cameraView.flashButton.isHidden = true
    self.pagesController.bottomView.showTimer()
    self.cameraMan.startVideoRecord(location: locationManager?.latestLocation, startCompletion: { result in })
  }
  
  func shutterButtonReleased() {
    self.cameraView.rotateButton.isHidden = false
    self.cameraView.flashButton.isHidden = false
    self.pagesController.bottomView.hideTimer()
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
    
    self.pagesController.cartButton.startLoading()
    cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation)
  }
  
  func switchedToState(state: MediaToolbarState) { }
  
  func pageDidHide() {
    self.cameraView.rotateButton.isHidden = false
    self.cameraView.flashButton.isHidden = false
  }
  
  func pageDidShow() {
    once.run {
      cameraMan.setup()
    }
    self.pagesController.mediaPickerController.rotateButtons()
  }

  var initialBottomViewState: MediaToolbarState {
    return .Camera
  }
  
  var pagesController: PagesController {
    return self.parent as! PagesController
  }
  
  func setupForOrientation(angle: CGFloat) {
    UIView.animate(withDuration: 0.2, animations: {
      self.cameraView.flashButton.transform = CGAffineTransform(rotationAngle: angle)
      self.cameraView.rotateButton.transform = CGAffineTransform(rotationAngle: angle)
    }, completion: nil)
  }
}

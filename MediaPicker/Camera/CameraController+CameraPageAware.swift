extension CameraController: CameraPageAware {
  func shutterButtonHeld() {
    MediaPickerConfig.instance.camera.recordMode = .video
    pagesController.topView.toggleViewsVisibility()
    pagesController.topView.showTimer()
    cameraMan.startVideoRecord(location: locationManager?.latestLocation, startCompletion: { result in })
  }
  
  func shutterButtonReleased() {
    pagesController.topView.toggleViewsVisibility()
    pagesController.topView.hideTimer()
    cameraMan.stopVideoRecording()
  }
  
  func shutterButtonTapped() {
    guard let previewLayer = cameraView.previewLayer else { return }

    self.pagesController.bottomView.shutterButton.isEnabled = false
    UIView.animate(withDuration: 0.1, animations: {
      self.cameraView.shutterOverlayView.alpha = 1
    }, completion: { _ in
      UIView.animate(withDuration: 0.1, animations: {
        self.cameraView.shutterOverlayView.alpha = 0
      })
    })
    
    self.pagesController.bottomView.cartButton.startLoading()
    cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation)
  }
  
  func switchedToState(state: MediaToolbarState) { }
  
  func pageDidHide() {
    if cameraMan.isRecording() {
      shutterButtonReleased()
    }
    pagesController.topView.rotateButton.isHidden = false
    pagesController.topView.flashButton.isHidden = false
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
      self.pagesController.topView.flashButton.transform = CGAffineTransform(rotationAngle: angle)
      self.pagesController.topView.rotateButton.transform = CGAffineTransform(rotationAngle: angle)
    }, completion: nil)
  }
}

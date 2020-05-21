import Photos

extension CameraController: CameraManDelegate {
  func cameraManDidStart(_ cameraMan: CameraMan) {
    cameraView.setupPreviewLayer(cameraMan.session)
    
    if let connection = self.cameraView.previewLayer?.connection,
      connection.isVideoOrientationSupported {
      connection.videoOrientation = Utils.videoOrientation()
    }
  }
  
  func cameraManNotAvailable(_ cameraMan: CameraMan) {
    cameraView.focusImageView.isHidden = true
  }
  
  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
    cameraView.flashButton.isHidden = !input.device.hasFlash
  }
  
  func takenAsset(_ cameraMan: CameraMan, asset: PHAsset?) {
    if Config.Camera.recordMode == .photo {
      self.pagesController.bottomView.shutterButton?.isEnabled = true

      if let asset = asset {
        let image = Image(asset: asset, guid: UUID().uuidString, newlyTaken: true, customFileName: FileNameComposer.getImageFileName(), dateAdded: Date())
        Config.BottomView.Cart.selectedGuid = image.guid
        self.cart.add(image)
        EventHub.shared.executeCustomAction?(image.guid)
      }
    } else {
      Config.Camera.recordMode = .photo
      if let asset = asset {
        let video = Video(asset: asset, guid: UUID().uuidString, customFileName: FileNameComposer.getVideoFileName(), newlyTaken: true, dateAdded: Date())
        Config.BottomView.Cart.selectedGuid = video.guid
        self.cart.add(video)
        EventHub.shared.executeCustomAction?(video.guid)
      }
    }
  }
}

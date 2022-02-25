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
    if MediaPickerConfig.instance.camera.recordMode == .photo {
      self.pagesController.bottomView.shutterButton?.isEnabled = true
      self.pagesController.cartButton.stopLoading()

      if let asset = asset {
        let image = Image(asset: asset, guid: UUID().uuidString, newlyTaken: true, customFileName: FileNameComposer.getImageFileName(), dateAdded: Date())
        MediaPickerConfig.instance.bottomView.cart.selectedGuid = image.guid
        self.cart.add(image)
        if MediaPickerConfig.instance.bottomView.cart.maxItems == 1 {
          EventHub.shared.executeCustomAction?(image.guid)
        }
      }
    } else {
      MediaPickerConfig.instance.camera.recordMode = .photo
      if let asset = asset {
        let video = Video(asset: asset, guid: UUID().uuidString, customFileName: FileNameComposer.getVideoFileName(), newlyTaken: true, dateAdded: Date())
        MediaPickerConfig.instance.bottomView.cart.selectedGuid = video.guid
        self.cart.add(video)
        if MediaPickerConfig.instance.bottomView.cart.maxItems == 1 {
          EventHub.shared.executeCustomAction?(video.guid)
        }
      }
    }
  }
}

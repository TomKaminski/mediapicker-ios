extension CameraController: CameraViewDelegate {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint) {
    cameraMan.focus(point)
  }
}

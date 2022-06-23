extension CameraController: CameraViewDelegate {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint) {
    cameraMan.focus(point)
  }
  
  func cameraView(_ cameraView: CameraView, didPinched pinch: UIPinchGestureRecognizer) {
    cameraMan.pinchToZoom(pinch)
  }
}

extension MediaPickerController: PermissionControllerDelegate {
  func permissionControllerDidFinish(_ controller: PermissionController, closeTapped: Bool) {
    if closeTapped {
      delegate?.mediaPickerDidCancel(self)
    } else if let pagesController = makePagesController() {
      addChildController(pagesController)
      controller.removeFromParentController()
    }
  }
}

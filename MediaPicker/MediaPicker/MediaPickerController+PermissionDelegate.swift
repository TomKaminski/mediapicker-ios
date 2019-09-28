extension MediaPickerController: PermissionControllerDelegate {
  func permissionControllerDidFinish(_ controller: PermissionController, closeTapped: Bool) {
    if closeTapped {
      self.navigationController?.popViewController(animated: true)
    } else if let pagesController = makePagesController() {
      addChildController(pagesController)
      controller.removeFromParentController()
    }
  }

}

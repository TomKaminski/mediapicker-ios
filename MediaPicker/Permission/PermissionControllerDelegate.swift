protocol PermissionControllerDelegate: AnyObject {
  func permissionControllerDidFinish(_ controller: PermissionController, closeTapped: Bool)
}

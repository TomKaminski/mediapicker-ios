public enum GalleryTab: Int {
  case libraryTab = 0
  case cameraTab = 1
  case audioTab = 2
  
  var hasPermission: Bool {
    switch self {
    case .libraryTab:
      return (Permission.Photos.status == .authorized || Permission.Photos.status == .restricted)
    case .cameraTab:
      return Permission.Camera.status == .authorized
    case .audioTab:
      return Permission.Microphone.status == .authorized
    }
  }
}

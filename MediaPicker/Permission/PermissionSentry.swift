
import Foundation
import Photos
import AVFoundation

struct Permission {
  
  enum Status {
    case notDetermined
    case restricted
    case denied
    case authorized
  }
  
  struct Photos {
    static var needsPermission: Bool {
      return MediaPickerConfig.instance.tabsToShow.firstIndex(of: .libraryTab) != nil
    }
    
    static var status: Status {
      switch PHPhotoLibrary.authorizationStatus() {
      case .notDetermined:
        return .notDetermined
      case .restricted:
        return .restricted
      case .denied:
        return .denied
      case .authorized:
        return .authorized
      case .limited:
        return .authorized
      @unknown default:
        return .notDetermined
      }
    }
    
    static func request(_ completion: @escaping () -> Void) {
      PHPhotoLibrary.requestAuthorization { status in
        completion()
      }
    }
  }
  
  struct Camera {
    static var needsPermission: Bool {
      return MediaPickerConfig.instance.tabsToShow.firstIndex(of: .cameraTab) != nil
    }
    
    static var status: Status {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .notDetermined:
        return .notDetermined
      case .restricted:
        return .restricted
      case .denied:
        return .denied
      case .authorized:
        return .authorized
      @unknown default:
        return .notDetermined
      }
    }
    
    static func request(_ completion: @escaping () -> Void) {
      AVCaptureDevice.requestAccess(for: .video) { granted in
        completion()
      }
    }
  }
  
  struct Microphone {
    static var needsPermission: Bool {
      return MediaPickerConfig.instance.tabsToShow.firstIndex(of: .cameraTab) != nil
    }
    
    static var status: Status {
      switch AVCaptureDevice.authorizationStatus(for: .audio) {
      case .notDetermined:
        return .notDetermined
      case .restricted:
        return .restricted
      case .denied:
        return .denied
      case .authorized:
        return .authorized
      @unknown default:
        return .notDetermined
      }
    }
    
    static func request(_ completion: @escaping () -> Void) {
      AVCaptureDevice.requestAccess(for: .audio) { granted in
        completion()
      }
    }
  }
}

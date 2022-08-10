
import Foundation
import Photos
import AVFoundation

struct Permission {
  public static var anyAuthorized: Bool {
    return Camera.status == .authorized || Microphone.status == .authorized || (Photos.status == .authorized || Photos.status == .restricted)
  }
  
  public static var startIndex: Int {
    return startTab.rawValue
  }
  
  public static var startTab: GalleryTab {
    return MediaPickerConfig.shared.initialTab
  }
  
  enum Status {
    case notDetermined
    case restricted
    case denied
    case authorized
  }
  
  struct Photos {
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


import Foundation
import Photos
import AVFoundation

struct Permission {
  public static var anyAuthorized: Bool {
    return Camera.status == .authorized || Microphone.status == .authorized || (Photos.status == .authorized || Photos.status == .restricted)
  }
  
  public static var startIndex: Int {
    guard anyAuthorized else {
      return 0
    }
    
    if startTab.hasPermission {
      return startTab.rawValue
    }
    
    if Camera.status == .authorized {
      return 1
    }
    
    if Photos.status == .authorized || Photos.status == .restricted {
      return 0
    }
    
    if Microphone.status == .authorized && MediaPickerConfig.shared.audio.includeAudioTab {
      return 2
    }
    
    return 0
  }
  
  public static var startTab: GalleryTab {
    guard anyAuthorized else {
      return .libraryTab
    }
    
    if MediaPickerConfig.shared.initialTab.hasPermission {
      return MediaPickerConfig.shared.initialTab
    }
    
    if Camera.status == .authorized {
      return .cameraTab
    }
    
    if Photos.status == .authorized || Photos.status == .restricted {
      return .libraryTab
    }
    
    if Microphone.status == .authorized && MediaPickerConfig.shared.audio.includeAudioTab {
      return .audioTab
    }
    
    return .libraryTab
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

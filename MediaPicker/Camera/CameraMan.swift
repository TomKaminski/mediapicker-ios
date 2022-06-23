import Foundation
import AVFoundation
import PhotosUI
import Photos

protocol CameraManDelegate: AnyObject {
  func cameraManNotAvailable(_ cameraMan: CameraMan)
  func cameraManDidStart(_ cameraMan: CameraMan)
  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
  func takenAsset(_ cameraMan: CameraMan, asset: PHAsset?)
}

class CameraMan : NSObject, AVCapturePhotoCaptureDelegate {
  weak var delegate: CameraManDelegate?
  
  let session = AVCaptureSession()
  let queue = DispatchQueue(label: "pl.tomkaminski.MediaPicker.Camera.SessionQueue", qos: .background)
  let savingQueue = DispatchQueue(label: "pl.tomkaminski.MediaPicker.Camera.SavingQueue", qos: .background)
  
  var backCamera: AVCaptureDeviceInput?
  var frontCamera: AVCaptureDeviceInput?
  var photoOutput: AVCapturePhotoOutput?
  var movieOutput: ClosuredAVCaptureMovieFileOutput?
  var photoSettings: AVCapturePhotoSettings!
  
  var zoomFactor: CGFloat = 1.0
  
  deinit {
    stop()
  }
  
  // MARK: - Setup
  
  func setup() {
    if Permission.Camera.status == .authorized {
      self.start()
    } else {
      self.delegate?.cameraManNotAvailable(self)
    }
  }
  
  func setupDevices() {
    // Input
    AVCaptureDevice.DiscoverySession.init(deviceTypes: [.builtInMicrophone, .builtInWideAngleCamera], mediaType: nil, position: AVCaptureDevice.Position.unspecified)
      .devices
      .filter {
        return $0.hasMediaType(.video)
      }.forEach {
        switch $0.position {
        case .front:
          self.frontCamera = try? AVCaptureDeviceInput(device: $0)
        case .back:
          self.backCamera = try? AVCaptureDeviceInput(device: $0)
        default:
          break
        }
    }
    
    // Output
    photoOutput = AVCapturePhotoOutput()
    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
    photoSettings.isAutoStillImageStabilizationEnabled = false
    movieOutput = ClosuredAVCaptureMovieFileOutput(sessionQueue: queue)
  }
  
  func addInput(_ input: AVCaptureDeviceInput) {
    configurePreset(input)
    
    if session.canAddInput(input) {
      session.addInput(input)
      
      DispatchQueue.main.async {
        self.delegate?.cameraMan(self, didChangeInput: input)
      }
    }
  }
  
  // MARK: - Session
  
  var currentInput: AVCaptureDeviceInput? {
    return session.inputs.first as? AVCaptureDeviceInput
  }
  
  fileprivate func start() {
    // Devices
    setupDevices()
    
    guard let input = backCamera, let imageOutput = photoOutput, let movieOutput = movieOutput else { return }
    
    addInput(input)
    
    if session.canAddOutput(imageOutput) {
      session.addOutput(imageOutput)
    }
    
    movieOutput.addToSession(session)
    
    queue.async {
      self.session.startRunning()
      
      DispatchQueue.main.async {
        self.delegate?.cameraManDidStart(self)
      }
    }
  }
  
  func stop() {
    self.session.stopRunning()
  }
  
  func switchCamera(_ completion: (() -> Void)? = nil) {
    guard let currentInput = currentInput
      else {
        completion?()
        return
    }
    
    queue.async {
      guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera
        else {
          DispatchQueue.main.async {
            completion?()
          }
          return
      }
      
      self.configure {
        self.session.removeInput(currentInput)
        self.addInput(input)
      }
      
      DispatchQueue.main.async {
        completion?()
      }
    }
  }
  
  @available(iOS 11.0, *)
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    guard let imageData = photo.fileDataRepresentation() else {
      debugPrint("Error while generating image from photo capture data.")
      self.delegate?.takenAsset(self, asset: nil)
      return
    }
    
    guard UIImage(data: imageData) != nil else {
      debugPrint("Unable to generate UIImage from image data.")
      self.delegate?.takenAsset(self, asset: nil)
      return
    }
        
    self.savePhoto(imageData, location: lastLocation, metadata: photo.metadata)
  }
    
  var lastLocation: CLLocation?
  
  func takePhoto(_ previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?) {
    guard let connection = photoOutput?.connection(with: .video) else { return }
    
    connection.videoOrientation = Utils.videoOrientation()
    lastLocation = location
    
    queue.async {
      self.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(from: self.photoSettings), delegate: self)
    }
  }
  
  func mergeImageData(imageData: Data, with metadata: [String: Any]) -> Data? {
    if let source: CGImageSource = CGImageSourceCreateWithData(imageData as NSData, nil), let UTI: CFString = CGImageSourceGetType(source) {
      let newImageData =  NSMutableData()
      if let cgImage = UIImage(data: imageData)?.cgImage, let imageDestination: CGImageDestination = CGImageDestinationCreateWithData((newImageData as CFMutableData), UTI, 1, nil) {
        CGImageDestinationAddImage(imageDestination, cgImage, metadata as CFDictionary)
        CGImageDestinationFinalize(imageDestination)
        return newImageData as Data
      }
    }
    
    return nil
  }
  
  func savePhoto(_ image: Data, location: CLLocation?, metadata: [String: Any]) {
    self.save({
      var changeRequest: PHAssetChangeRequest
      if !metadata.isEmpty, let newImageData = self.mergeImageData(imageData: image, with: metadata) {
          changeRequest = PHAssetCreationRequest.forAsset()
          (changeRequest as! PHAssetCreationRequest).addResource(with: .photo, data: newImageData as Data, options: nil)
      }
      else {
          changeRequest = PHAssetChangeRequest.creationRequestForAsset(from: UIImage(data: image)!)
      }
      return changeRequest
    }, location: location)
  }
  
  func save(_ req: @escaping (() -> PHAssetChangeRequest?), location: CLLocation?) {
    var localIdentifier: String?
    
    savingQueue.async {
      do {
        try PHPhotoLibrary.shared().performChangesAndWait {
          if let request = req() {
            localIdentifier = request.placeholderForCreatedAsset?.localIdentifier
            
            request.creationDate = Date()
            request.location = location
          }
        }
        
        DispatchQueue.main.async {
          if let localIdentifier = localIdentifier {
            self.delegate?.takenAsset(self, asset: Fetcher.fetchAsset(localIdentifier))
          } else {
            self.delegate?.takenAsset(self, asset: nil)
          }
        }
      } catch {
        DispatchQueue.main.async {
          self.delegate?.takenAsset(self, asset: nil)
        }
      }
    }
  }
  
  func flash(_ mode: AVCaptureDevice.FlashMode) {
    guard let device = currentInput?.device, device.isFlashAvailable else { return }
//TODO: Enable when Cocoapods is fixed.
//    guard photoOutput?.supportedFlashModes.contains(mode) == true else { return }
    self.photoSettings.flashMode = mode
  }
  
  func focus(_ point: CGPoint) {
    guard let device = currentInput?.device, device.isFocusModeSupported(AVCaptureDevice.FocusMode.locked) else { return }
    
    queue.async {
      self.lock {
        device.focusPointOfInterest = point
        device.focusMode = .autoFocus
      }
    }
  }
  
  func pinchToZoom(_ pinch: UIPinchGestureRecognizer) {
    guard let device = currentInput?.device else { return }

    func minMaxZoom(_ factor: CGFloat) -> CGFloat { return min(max(factor, 1.0), 5) }

    func update(scale factor: CGFloat) {
      do {
        try device.lockForConfiguration()
        defer { device.unlockForConfiguration() }
        device.videoZoomFactor = factor
      } catch {
        debugPrint(error)
      }
    }

    let newScaleFactor = minMaxZoom(pinch.scale * zoomFactor)

    switch pinch.state {
      case .began: fallthrough
      case .changed: update(scale: newScaleFactor)
      case .ended:
        zoomFactor = minMaxZoom(newScaleFactor)
        update(scale: zoomFactor)
     default: break
   }
 }
  
  // MARK: - Lock
  
  func lock(_ block: () -> Void) {
    if let device = currentInput?.device, (try? device.lockForConfiguration()) != nil {
      block()
      device.unlockForConfiguration()
    }
  }
  
  // MARK: - Configure
  func configure(_ block: () -> Void) {
    session.beginConfiguration()
    block()
    session.commitConfiguration()
  }
  
  // MARK: - Preset
  
  func configurePreset(_ input: AVCaptureDeviceInput) {
    for asset in preferredPresets() {
      if input.device.supportsSessionPreset(asset) && self.session.canSetSessionPreset(asset) {
        self.session.sessionPreset = asset
        return
      }
    }
  }
  
  func preferredPresets() -> [AVCaptureSession.Preset] {
    return [
      .high,
      .medium,
      .low
    ]
  }
  
  func isRecording() -> Bool {
    return self.movieOutput?.isRecording() ?? false
  }
  
  func startVideoRecord(location: CLLocation?, startCompletion: ((Bool) -> Void)?) {
    lastLocation = location
    
    self.movieOutput?.startRecording(startCompletion: startCompletion, stopCompletion: { url in
      if let url = url {
        self.saveVideo(at: url, location: location)
      } else {
        self.delegate?.takenAsset(self, asset: nil)
      }
    })
  }
  
  func stopVideoRecording() {
    self.movieOutput?.stopVideoRecording()
  }
  
  func saveVideo(at path: URL, location: CLLocation?) {
    self.save({
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: path)
    }, location: location)
  }
}

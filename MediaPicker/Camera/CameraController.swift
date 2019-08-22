import UIKit
import AVFoundation
import Foundation
import AVKit
import QuartzCore
import Photos

class CameraController: UIViewController {
  lazy var cameraMan: CameraMan = self.makeCameraMan()
  lazy var cameraView: CameraView = self.makeCameraView()
  
  let once = Once()
  let cart: Cart
  
  // MARK: - Init
  public required init(cart: Cart) {
    self.cart = cart
    super.init(nibName: nil, bundle: nil)
    cart.delegates.add(self)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { _ in
      if let connection = self.cameraView.previewLayer?.connection,
        connection.isVideoOrientationSupported {
        connection.videoOrientation = Utils.videoOrientation()
      }
    }, completion: nil)
    
    super.viewWillTransition(to: size, with: coordinator)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
  }
  
  func setup() {
    view.addSubview(cameraView)
    cameraView.g_pinEdges()
    
    cameraView.flashButton.addTarget(self, action: #selector(flashButtonTouched(_:)), for: .touchUpInside)
    cameraView.rotateButton.addTarget(self, action: #selector(rotateButtonTouched(_:)), for: .touchUpInside)
  }
  
  @objc func flashButtonTouched(_ button: UIButton) {
    cameraView.flashButton.toggle()
    
    if let flashMode = AVCaptureDevice.FlashMode(rawValue: cameraView.flashButton.selectedIndex) {
      cameraMan.flash(flashMode)
    }
  }
  
  @objc func rotateButtonTouched(_ button: UIButton) {
    UIView.animate(withDuration: 0.3, animations: {
      self.cameraView.rotateOverlayView.alpha = 1
    }, completion: { _ in
      self.cameraMan.switchCamera {
        UIView.animate(withDuration: 0.7, animations: {
          self.cameraView.rotateOverlayView.alpha = 0
        })
      }
    })
  }
  
  func makeCameraMan() -> CameraMan {
    let man = CameraMan()
    man.delegate = self
    
    return man
  }
  
  func makeCameraView() -> CameraView {
    let view = CameraView()
    view.delegate = self
    
    return view
  }

  
  func shutterButtonAction() {
    guard let previewLayer = cameraView.previewLayer else { return }
    
    switch Config.Camera.recordMode {
    case .photo:
      self.pagesController.bottomView.shutterButton?.isEnabled = false
      UIView.animate(withDuration: 0.1, animations: {
        self.cameraView.shutterOverlayView.alpha = 1
      }, completion: { _ in
        UIView.animate(withDuration: 0.1, animations: {
          self.cameraView.shutterOverlayView.alpha = 0
        })
      })
  
      cameraMan.takePhoto(previewLayer, location: nil)
    case .video:
      break;
//      if self.cameraMan.isRecording() {
//        button.isEnabled = false
//        self.cameraView.morphToVideoRecordingSavingStarted()
//        self.cameraMan.stopVideoRecording()
//      } else {
//        button.isEnabled = false
//        self.cameraMan.startVideoRecord(location: nil, startCompletion: { result in
//          button.isEnabled = true
//          self.cameraView.morphToVideoRecordingStarted()
//        })
//      }
    }
  }
}

extension CameraController: CameraViewDelegate {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint) {
    cameraMan.focus(point)
  }
}

extension CameraController: PageAware {
  func shutterButtonTouched() {
    self.shutterButtonAction()
  }
  
  func switchedToState(state: MediaToolbarState) {
    if (state == .Camera) {
//      self.pagesController.bottomView.shutterButton?.addTarget(self, action: #selector(shutterButtonTouched(_:)), for: .touchUpInside)
    }
  }
  
  
  func pageDidHide() {
    //self.stopVideoRecordingIfStarted()
  }
  
  func pageDidShow() {
    
//    if let video = self.cart.video {
//      self.videoBox.imageView.g_loadImage(video.asset)
//    }
//    
    once.run {
      cameraMan.setup()
    }
//
//    self.pagesController.bottomView.shutterButton!.addTarget(self, action: #selector(shutterButtonTouched(_:)), for: .touchUpInside)
  }

  var initialBottomViewState: MediaToolbarState {
    return .Camera
  }
  
  var pagesController: PagesController {
    return self.parent as! PagesController
  }
}

extension CameraController: CartDelegate {
  func cart(_ cart: Cart, didAdd video: Video) {
    
  }
  
  func cart(_ cart: Cart, didAdd audio: Audio) {
    
  }
  
  func cart(_ cart: Cart, didAdd image: Image) {
    
  }
  
  func cart(_ cart: Cart, didRemove image: Image) {
    
  }
  
  func cart(_ cart: Cart, didRemove audio: Audio) {
    
  }
  
  func cart(_ cart: Cart, didRemove video: Video) {
    
  }
  
  func cartDidReload(_ cart: Cart) {
    
  }
  
  var basicBottomViewState: MediaToolbarState {
    return .Camera
  }
}

extension CameraController: CameraManDelegate {
  func cameraManDidStart(_ cameraMan: CameraMan) {
    cameraView.setupPreviewLayer(cameraMan.session)
  }
  
  func cameraManNotAvailable(_ cameraMan: CameraMan) {
    cameraView.focusImageView.isHidden = true
  }
  
  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
    cameraView.flashButton.isHidden = !input.device.hasFlash
  }
  
  func takenAsset(_ cameraMan: CameraMan, asset: PHAsset?) {
    if Config.Camera.recordMode == .photo {
      self.pagesController.bottomView.shutterButton?.isEnabled = true

      if let asset = asset {
        self.cart.add(Image(asset: asset, guid: UUID().uuidString))
      }
    } else {
//      self.cameraView.shutterButton.isEnabled = true
//      self.cameraView.morphToVideoRecordingSavingDone()
//      if let asset = asset {
//        self.cart.setVideo(Video(asset: asset))
//      }
    }
  }
}


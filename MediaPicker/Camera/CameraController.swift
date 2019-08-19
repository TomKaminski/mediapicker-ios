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

}

extension CameraController: CameraViewDelegate {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint) {
    cameraMan.focus(point)
  }
}

extension CameraController: PageAware {
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
  }

  var initialBottomViewState: MediaToolbarState {
    return .Camera
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
//    if Config.Camera.recordMode == .photo {
//      self.cameraView.shutterButton.isEnabled = true
//      self.cameraView.stackView.stopLoading()
//      
//      if let asset = asset {
//        originalImageAsset = Image(asset: asset)
//        originalImageAsset?.resolve { (originalImage) in
//          guard let originalImage = originalImage else {
//            self.cart.add(self.originalImageAsset!, newlyTaken: true)
//            return
//          }
//          
//          let photoEditor = PhotoEditorViewController(nibName: "PhotoEditorViewController", bundle: Bundle(for: PhotoEditorViewController.self))
//          photoEditor.photoEditorDelegate = self
//          photoEditor.image = originalImage
//          self.present(photoEditor, animated: true, completion: nil)
//        }
//      }
//    } else {
//      self.cameraView.shutterButton.isEnabled = true
//      self.cameraView.morphToVideoRecordingSavingDone()
//      if let asset = asset {
//        self.cart.setVideo(Video(asset: asset))
//      }
//    }
  }
}


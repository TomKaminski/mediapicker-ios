import UIKit
import AVFoundation
import Foundation
import AVKit
import QuartzCore
import Photos
import QuickLook
import PhotosUI

class CameraController: UIViewController, CameraTabTopViewDelegate {
  var locationManager: LocationManager?

  lazy var cameraMan: CameraMan = self.makeCameraMan()
  lazy var cameraView: CameraView = self.makeCameraView()
  
  let once = Once()
  let cart: Cart
  
  var takenAssetUrl: NSURL?
  
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
    setupLocation()
    
    pagesController?.topView.cameraDelegate = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    locationManager?.start()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    locationManager?.stop()
  }
  
  func setupLocation() {
    if MediaPickerConfig.shared.camera.recordLocation {
      locationManager = LocationManager()
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { _ in
      if let connection = self.cameraView.previewLayer?.connection,
        connection.isVideoOrientationSupported {
        connection.videoOrientation = Utils.videoOrientation()
      }
    }, completion: nil)
    
    cameraView.previewLayer?.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    
    super.viewWillTransition(to: size, with: coordinator)
  }
  
  func setup() {
    view.addSubview(cameraView)
    cameraView.translatesAutoresizingMaskIntoConstraints = false
    cameraView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    cameraView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    cameraView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
    cameraView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
  }
  
  func onFlashToggle(selectedIndex: Int) {
    if let flashMode = AVCaptureDevice.FlashMode(rawValue: selectedIndex) {
      cameraMan.flash(flashMode)
    }
  }
  
  func onRotateToggle() {
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

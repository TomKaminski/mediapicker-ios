import UIKit
import AVFoundation
import Foundation
import AVKit
import QuartzCore
import Photos
import QuickLook
import PhotosUI

class CameraController: UIViewController {
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

import Photos

public class MediaPickerController: UIViewController {
    
  public weak var delegate: MediaPickerControllerDelegate?
  
  let cart = Cart()
  var pagesController: PagesController?
  
  var pagesBottomContraint: NSLayoutConstraint?
  var pagesBottomActiveKeyboardContraint: NSLayoutConstraint?
  
  var currentlyPresentedModalController: MediaModalBaseController?
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(rotateButtons), name: UIDevice.orientationDidChangeNotification, object: nil)
    
    setupEventHub()
    self.cart.cartMainDelegate = self
    
    if let pagesController = makePagesController() {
      addChildController(pagesController)
      addChild(pagesController)
      view.addSubview(pagesController.view)
      pagesController.didMove(toParent: self)
      
      pagesController.view.g_pin(on: .top)
      pagesBottomContraint = pagesController.view.g_pin(on: .bottom)
      pagesController.view.g_pin(on: .left)
      pagesController.view.g_pin(on: .right)
    } else {
      let permissionController = makePermissionController()
      addChildController(permissionController)
    }
    
    setNeedsStatusBarAppearanceUpdate()
  }

  @objc public func rotateButtons() {
    guard UIDevice.current.userInterfaceIdiom != .pad else {
      return
    }
    var angle: CGFloat = 0
       
    switch UIDevice.current.orientation {
    case .landscapeLeft:
      angle = (CGFloat(Double.pi) / 2)
    case .landscapeRight:
      angle = (CGFloat(-Double.pi) / 2)
    case .portraitUpsideDown:
      angle = CGFloat(Double.pi)
    case .unknown, .portrait, .faceUp, .faceDown:
      angle = 0
    default:
      angle = 0
    }

    self.pagesController?.activeController?.setupForOrientation(angle: angle)
    
    UIView.animate(withDuration: 0.2, animations: {
      self.pagesController?.cartButton.transform = CGAffineTransform(rotationAngle: angle)
      self.pagesController?.bottomView.saveButton?.transform = CGAffineTransform(rotationAngle: angle)
      self.pagesController?.bottomView.backButton?.transform = CGAffineTransform(rotationAngle: angle)
    }, completion: nil)
  }
  
  fileprivate func presentNewModal(_ modalCtrl: MediaModalBaseController?, _ newGuid: String) {
    if let modalCtrl = modalCtrl {
      if let currentModalCtrl = self.currentlyPresentedModalController {
        currentModalCtrl.updateNewlyTaken()
        currentModalCtrl.dismiss(animated: true) {
          self.present(modalCtrl, animated: true, completion: {
            self.currentlyPresentedModalController = modalCtrl
          })
        }
      } else {
        self.present(modalCtrl, animated: true, completion: {
          self.currentlyPresentedModalController = modalCtrl
        })
      }
    }
  }
  
  func setupEventHub() {
    EventHub.shared.modalDismissed = { onAddNextTapped in
      if onAddNextTapped {
        self.currentlyPresentedModalController?.customOnAddNexTap(doneWithMediaTapped: false)
      }
      
      self.currentlyPresentedModalController?.dismiss(animated: false, completion: nil)
      if let guid = MediaPickerConfig.instance.bottomView.cart.selectedGuid, let cartItem = self.cart.getItem(by: guid), cartItem.newlyTaken, !onAddNextTapped {
        self.cart.remove(cartItem)
      }
      MediaPickerConfig.instance.bottomView.cart.selectedGuid = nil
      self.currentlyPresentedModalController = nil
      self.pagesController?.bottomView.cartView?.reselectItem()
    }
    
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        if !strongSelf.cart.items.isEmpty {
          let alertController = UIAlertController(title: MediaPickerConfig.instance.translationKeys.discardCartItemsKey.g_localize(fallback: "Discard elements"), message: String(format: MediaPickerConfig.instance.translationKeys.discardCartItemsDescriptionKey.g_localize(fallback: "Are you sure you want to discard this elements?"), strongSelf.cart.items.count), preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.discardKey.g_localize(fallback: "Discard"), style: .destructive, handler: { _ in
            strongSelf.dismiss(animated: true, completion: nil)
          }))
          alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel"), style: .cancel, handler: nil))
          strongSelf.present(alertController, animated: true, completion: nil)
        } else {
          strongSelf.dismiss(animated: true, completion: nil)
        }
      }
    }
    
    EventHub.shared.doneWithMedia = { [weak self] in
      if let strongSelf = self {
        if let modalCtrl = strongSelf.currentlyPresentedModalController {
          if modalCtrl is PhotoEditorController {
            modalCtrl.customOnAddNexTap(doneWithMediaTapped: true)
          } else {
            modalCtrl.updateNewlyTaken()
            modalCtrl.dismiss(animated: false) {
              strongSelf.delegate?.mediaPicker(strongSelf, didSelectMedia: strongSelf.cart.items.values.compactMap { $0 })
            }
          }
        } else {
          strongSelf.delegate?.mediaPicker(strongSelf, didSelectMedia: strongSelf.cart.items.values.compactMap { $0 })
        }
      }
    }
    
    EventHub.shared.executeCustomAction = { guid in
      if let item = self.cart.getItem(by: guid) {
        MediaPickerConfig.instance.bottomView.cart.selectedGuid = guid
        if item.type == .Image && MediaPickerConfig.instance.camera.allowPhotoEdit {
          let image = item as! Image
          image.resolve(completion: { (uiImage) in
            let photoEditor = PhotoEditorController(image: uiImage!, guid: item.guid, newlyTaken: image.newlyTaken)
            photoEditor.modalPresentationStyle = .overFullScreen
            photoEditor.customFileName = image.customFileName
            photoEditor.photoEditorDelegate = self
            photoEditor.mediaPickerControllerDelegate = self.pagesController
            self.pagesController?.bottomView.cartView?.reselectItem()
            self.presentNewModal(photoEditor, guid)
          })
        } else if item.type == .Audio && MediaPickerConfig.instance.audio.allowAudioEdit {
          let ctrl = AudioPreviewController(audio: item as! Audio)
          ctrl.mediaPickerControllerDelegate = self.pagesController
          ctrl.customFileName = item.customFileName
          ctrl.modalPresentationStyle = .overFullScreen
          self.pagesController?.bottomView.cartView?.reselectItem()
          self.presentNewModal(ctrl, guid)
        } else if item.type == .Video && MediaPickerConfig.instance.camera.allowVideoEdit {
          let assetCtrl = VideoAssetPreviewController()
          assetCtrl.video = (item as! Video)
          assetCtrl.customFileName = item.customFileName
          assetCtrl.mediaPickerControllerDelegate = self.pagesController
          assetCtrl.modalPresentationStyle = .overFullScreen
          self.pagesController?.bottomView.cartView?.reselectItem()
          self.presentNewModal(assetCtrl, guid)
        }
      }
    }
  }
  
  public override var shouldAutorotate: Bool {
    return true
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  func makePermissionController() -> PermissionController {
    let controller = PermissionController()
    controller.delegate = self
    return controller
  }
    
  func makePagesController() -> PagesController? {
    guard Permission.anyAuthorized else {
      return nil
    }
    
    let controllers = [
      createLibraryController(),
      createCameraController(),
      createAudioController()
    ]

    let controller = PagesController(controllers: controllers)
    self.pagesController = controller
    controller.selectedIndex = Permission.startIndex

    return controller
  }

  func createCameraController() -> UIViewController {
    guard Permission.Camera.status == .authorized else {
      return UIViewController()
    }

    let ctrl = CameraController(cart: self.cart)
    ctrl.title = MediaPickerConfig.instance.translationKeys.cameraTabTitleKey.g_localize(fallback: "CAMERA")
    return ctrl
  }

  func createAudioController() -> UIViewController {
    guard Permission.Microphone.status == .authorized else {
      return UIViewController()
    }

    let ctrl = AudioController(cart: self.cart)
    ctrl.title = MediaPickerConfig.instance.translationKeys.audioTabTitleKey.g_localize(fallback: "AUDIO")
    return ctrl
  }

  func createLibraryController() -> LibraryController {
    let ctrl = LibraryController(cart: cart)
    ctrl.title = MediaPickerConfig.instance.translationKeys.libraryTabTitleKey.g_localize(fallback: "LIBRARY")
    return ctrl
  }
}

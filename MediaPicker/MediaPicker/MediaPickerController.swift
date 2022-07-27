import Photos

public class MediaPickerController: UIViewController {
  public weak var delegate: MediaPickerControllerDelegate?
  
  let cart = Cart()
  
  var pagesController: PagesController?
  var currentlyPresentedModalController: MediaEditorBaseController?

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    NotificationCenter.default.addObserver(self, selector: #selector(rotateButtons), name: UIDevice.orientationDidChangeNotification, object: nil)
    
    setupEventHub()
    cart.cartMainDelegate = self
    
    if let pagesController = makePagesController() {
      addChildController(pagesController)
      addChild(pagesController)
      view.addSubview(pagesController.view)
      pagesController.didMove(toParent: self)
      pagesController.view.g_pinEdges()
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
      self.pagesController?.bottomView.cartButton.transform = CGAffineTransform(rotationAngle: angle)
      self.pagesController?.bottomView.saveButton.transform = CGAffineTransform(rotationAngle: angle)
    }, completion: nil)
  }
  
  func setupEventHub() {
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        if !strongSelf.cart.items.isEmpty {
          let title = MediaPickerConfig.shared.translationKeys.discardElementKey.g_localize(fallback: "Discard element")
          let message = MediaPickerConfig.shared.translationKeys.discardElementDescriptionKey.g_localize(fallback: "Are you sure you want to discard?")
          let discardBtnText = MediaPickerConfig.shared.translationKeys.discardKey.g_localize(fallback: "Discard")
          let cancelBtnText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
          
          if let dialogBuilder = MediaPickerConfig.shared.dialogBuilder, let controller = dialogBuilder(title, message, [
            (cancelBtnText, "cancel", nil),
            (discardBtnText, "delete", { strongSelf.dismiss(animated: true, completion: nil)  })
          ]) {
            strongSelf.present(controller, animated: true, completion: nil)
          } else {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: discardBtnText, style: .destructive, handler: { _ in
              strongSelf.dismiss(animated: true, completion: nil)
            }))
            strongSelf.present(alertController, animated: true, completion: nil)
          }
        } else {
          strongSelf.dismiss(animated: true, completion: nil)
        }
      }
    }
    
    EventHub.shared.doneWithMediaPicker = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.mediaPicker(strongSelf, didSelectMedia: strongSelf.cart.items.values.compactMap { $0 })
      }
    }
    
    EventHub.shared.executeCustomAction = { guid in
      if let item = self.cart.getItem(by: guid) {
        MediaPickerConfig.shared.cart.selectedGuid = guid
        if item.type == .Image && MediaPickerConfig.shared.camera.allowPhotoEdit {
          let image = item as! Image
          image.resolve(completion: { (uiImage) in
            let photoEditor = PhotoEditorController(image: uiImage!, guid: item.guid)
            photoEditor.modalPresentationStyle = .overFullScreen
            photoEditor.customFileName = image.customFileName
            photoEditor.delegate = self
            photoEditor.renameDelegate = self
            self.present(photoEditor, animated: true, completion: {
              self.currentlyPresentedModalController = photoEditor
            })
          })
        } else if item.type == .Audio && MediaPickerConfig.shared.audio.allowAudioEdit, let audio = item as? Audio {
          let audioCtrl = MediaPreviewController(url: audio.audioFile.url, guid: audio.guid, customFileName: audio.customFileName)
          audioCtrl.renameDelegate = self
          audioCtrl.customFileName = item.customFileName
          audioCtrl.modalPresentationStyle = .overFullScreen
          self.present(audioCtrl, animated: true, completion: {
            self.currentlyPresentedModalController = audioCtrl
          })
        } else if item.type == .Video && MediaPickerConfig.shared.camera.allowVideoEdit {
          let videoCtrl = VideoAssetPreviewController()
          videoCtrl.video = (item as! Video)
          videoCtrl.customFileName = item.customFileName
          videoCtrl.renameDelegate = self
          videoCtrl.modalPresentationStyle = .overFullScreen
          self.present(videoCtrl, animated: true, completion: {
            self.currentlyPresentedModalController = videoCtrl
          })
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
    
    var controllers = [
      createLibraryController(),
      createCameraController(),
    ]
    
    let showAudioTab = MediaPickerConfig.shared.audio.includeAudioTab
    if (showAudioTab) {
      controllers.append(createAudioController())
    }
    
    let controller = PagesController(controllers: controllers)
    pagesController = controller
    controller.selectedIndex = Permission.startIndex

    return controller
  }

  func createCameraController() -> UIViewController {
    guard Permission.Camera.status == .authorized else {
      return UIViewController()
    }

    let ctrl = CameraController(cart: cart)
    ctrl.title = MediaPickerConfig.shared.translationKeys.cameraTabTitleKey.g_localize(fallback: "CAMERA")
    return ctrl
  }

  func createAudioController() -> UIViewController {
    guard Permission.Microphone.status == .authorized else {
      return UIViewController()
    }

    let ctrl = AudioController(cart: cart)
    ctrl.title = MediaPickerConfig.shared.translationKeys.audioTabTitleKey.g_localize(fallback: "AUDIO")
    return ctrl
  }

  func createLibraryController() -> LibraryController {
    let ctrl = LibraryController(cart: cart)
    ctrl.title = MediaPickerConfig.shared.translationKeys.libraryTabTitleKey.g_localize(fallback: "LIBRARY")
    return ctrl
  }
}

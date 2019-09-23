import Photos

public class MediaPickerController: UIViewController, PermissionControllerDelegate {
  let cart = Cart()
  var pagesController: PagesController?
  
  var pagesBottomContraint: NSLayoutConstraint?
  var pagesBottomActiveKeyboardContraint: NSLayoutConstraint?

  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupEventHub()
    self.cart.cartMainDelegate = self
    
    if let pagesController = makePagesController() {
      addChildController(pagesController)
      addChild(pagesController)
      view.addSubview(pagesController.view)
      pagesController.didMove(toParent: self)
      
      pagesController.view.g_pin(on: .topMargin)
      pagesBottomContraint = pagesController.view.g_pin(on: .bottom)
      pagesController.view.g_pin(on: .left)
      pagesController.view.g_pin(on: .right)
    } else {
      let permissionController = makePermissionController()
      addChildController(permissionController)
    }
  }
  
  func setupEventHub() {
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        strongSelf.dismiss(animated: true, completion: nil)
      }
    }
    
    EventHub.shared.doneWithMedia = { [weak self] in
      //TODO
      print(self!)
    }
    
    EventHub.shared.executeCustomAction = { guid in
      if let item = self.cart.getItem(by: guid) {
        if item.type == .Image {
          let image = item as! Image
          image.resolve(completion: { (uiImage) in
            let photoEditor = PhotoEditorController(image: uiImage!, guid: item.guid)
            photoEditor.customFileName = image.customFileName
            photoEditor.photoEditorDelegate = self
            self.present(photoEditor, animated: true, completion: nil)
          })
        } else if item.type == .Audio {
          let ctrl = AudioPreviewController(audio: item as! Audio)
          ctrl.mediaPickerControllerDelegate = self.pagesController
          self.present(ctrl, animated: true, completion: nil)
        } else if item.type == .Video {
          let assetCtrl = VideoAssetPreviewController()
          assetCtrl.video = (item as! Video)
          self.present(assetCtrl, animated: true, completion: nil)
        }
      }
    }
    
    EventHub.shared.selfDeleteFromCart = { guid in
      self.cart.remove(guidToRemove: guid)
    }
  }
  
  public override var shouldAutorotate: Bool {
    return true
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

  //-------------
  //PERMISSION CONTROLLER
  //-------------

  func permissionControllerDidFinish(_ controller: PermissionController, closeTapped: Bool) {
    if closeTapped {
      self.navigationController?.popViewController(animated: true)
    } else if let pagesController = makePagesController() {
      addChildController(pagesController)
      controller.removeFromParentController()
    }
  }

  func makePermissionController() -> PermissionController {
    let controller = PermissionController()
    controller.delegate = self

    return controller
  }
  
  //-------------
  //END PERMISSION CONTROLLER
  //-------------
  
  
  
  //-------------
  //PAGES CONTROLLERS
  //-------------
  
  func makePagesController() -> PagesController? {
    guard Permission.Photos.status == .authorized else {
      return nil
    }

    let controllers: [UIViewController] = Config.tabsToShow.compactMap { tab in
      if tab == .libraryTab {
        return createLibraryController()
      } else if tab == .cameraTab {
        return createCameraController()
      } else if tab == .audioTab {
        return createAudioController()
      }
      return nil
    }

    guard !controllers.isEmpty else {
      return nil
    }

    let controller = PagesController(controllers: controllers)
    self.pagesController = controller
    let useCamera = Permission.Camera.status == .authorized
    controller.selectedIndex = useCamera ? 1 : 0

    return controller
  }

  func createCameraController() -> UIViewController? {
    guard Permission.Camera.status == .authorized else {
      return nil
    }

    let ctrl = CameraController(cart: self.cart)
    ctrl.title = Config.Camera.title
    return ctrl
  }

  func createAudioController() -> UIViewController? {
    guard Permission.Microphone.status == .authorized else {
      return nil
    }

    let ctrl = AudioController(cart: self.cart)
    ctrl.title = Config.Audio.title
    return ctrl
  }

  func createLibraryController() -> LibraryController {
    let ctrl = LibraryController(cart: cart)
    ctrl.title = Config.Library.title
    return ctrl
  }
  
  //-------------
  //END PAGES CONTROLLERS
  //-------------
}

extension MediaPickerController: CartMainDelegate {
  public func itemAdded(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartView?.addItem(item: item)
  }
  
  public func itemRemoved(item: CartItemProtocol) {
    self.pagesController?.bottomView.cartView?.removeItem(item: item)
  }
}

extension MediaPickerController: PhotoEditorDelegate {
  public func doneEditing(image: UIImage, customFileName: String?, selfCtrl: PhotoEditorController, editedSomething: Bool) {
    guard editedSomething else {
      selfCtrl.dismiss(animated: true, completion: nil)
      return
    }
    
    var localId: String?
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
      localId = request.placeholderForCreatedAsset?.localIdentifier
    }) { (success, error) in
      DispatchQueue.main.async {
        if let localId = localId {
          let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
          let newAsset = result.object(at: 0)
          
          self.cart.remove(guidToRemove: selfCtrl.originalImageGuid)
          self.cart.add(Image(asset: newAsset, guid: UUID().uuidString, customFileName: customFileName))
          selfCtrl.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
  public func canceledEditing() {
    
  }
}

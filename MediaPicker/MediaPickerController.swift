import Photos

public protocol MediaPickerControllerDelegate: AnyObject {

  func mediaPicker(_ controller: MediaPickerController, didSelectMedia media: [CartItemProtocol])

  func galleryControllerDidCancel(_ controller: MediaPickerController)
}

public class MediaPickerController: UIViewController, PermissionControllerDelegate {
  
  public weak var delegate: MediaPickerControllerDelegate?
  
  let cart = Cart()
  var pagesController: PagesController?
  
  var pagesBottomContraint: NSLayoutConstraint?
  var pagesBottomActiveKeyboardContraint: NSLayoutConstraint?
  
  var currentlyPresentedModalController: MediaModalBaseController?

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
  
  fileprivate func presentNewModal(_ modalCtrl: MediaModalBaseController?, _ newGuid: String) {
    if let modalCtrl = modalCtrl {
      if let currentModalCtrl = self.currentlyPresentedModalController {
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
    EventHub.shared.modalDismissed = {
      if let guid = Config.BottomView.Cart.selectedGuid, let cartItem = self.cart.getItem(by: guid), cartItem.newlyTaken {
        self.cart.remove(cartItem)
      }
      Config.BottomView.Cart.selectedGuid = nil
      self.currentlyPresentedModalController = nil
      self.pagesController?.bottomView.cartView?.reselectItem()
    }
    
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        if !strongSelf.cart.items.isEmpty {
          let alertController = UIAlertController(title: "Discard elements", message: "Are you sure you want to discard \(strongSelf.cart.items.count) elements?", preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
            alertController.dismiss(animated: true) {
              strongSelf.dismiss(animated: true, completion: nil)
            }
          }))
          alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (_) in
            alertController.dismiss(animated: true, completion: nil)
          }))
          strongSelf.present(alertController, animated: true, completion: nil)
        } else {
          strongSelf.dismiss(animated: true, completion: nil)
        }
      }
    }
    
    EventHub.shared.doneWithMedia = { [weak self] in
      if let strongSelf = self {
        if let modalCtrl = strongSelf.currentlyPresentedModalController {
          modalCtrl.dismiss(animated: false) {
            strongSelf.delegate?.mediaPicker(strongSelf, didSelectMedia: strongSelf.cart.items.values.compactMap { $0 })
          }
        } else {
          strongSelf.delegate?.mediaPicker(strongSelf, didSelectMedia: strongSelf.cart.items.values.compactMap { $0 })
        }
      }
    }
    
    EventHub.shared.executeCustomAction = { guid in
      if let item = self.cart.getItem(by: guid) {
        print(item.type)
        if item.type == .Image {
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
        } else if item.type == .Audio {
          let ctrl = AudioPreviewController(audio: item as! Audio)
          ctrl.mediaPickerControllerDelegate = self.pagesController
          ctrl.customFileName = item.customFileName
          self.pagesController?.bottomView.cartView?.reselectItem()
          self.presentNewModal(ctrl, guid)
        } else if item.type == .Video {
          let assetCtrl = VideoAssetPreviewController()
          assetCtrl.video = (item as! Video)
          assetCtrl.customFileName = item.customFileName
          assetCtrl.mediaPickerControllerDelegate = self.pagesController
          self.pagesController?.bottomView.cartView?.reselectItem()
          self.presentNewModal(assetCtrl, guid)
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
    ctrl.title = Config.Camera.title.g_localize(fallback: "CAMERA")
    return ctrl
  }

  func createAudioController() -> UIViewController? {
    guard Permission.Microphone.status == .authorized else {
      return nil
    }

    let ctrl = AudioController(cart: self.cart)
    ctrl.title = Config.Audio.title.g_localize(fallback: "AUDIO")
    return ctrl
  }

  func createLibraryController() -> LibraryController {
    let ctrl = LibraryController(cart: cart)
    ctrl.title = Config.Library.title.g_localize(fallback: "LIBRARY")
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
  public func doneEditing(image: UIImage, customFileName: String, selfCtrl: PhotoEditorController, editedSomething: Bool) {
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
          self.cart.add(Image(asset: newAsset, guid: UUID().uuidString, newlyTaken: false, customFileName: customFileName))
          selfCtrl.dismiss(animated: true, completion: nil)
        }
      }
    }
  }
  
  public func canceledEditing() {
    
  }
}

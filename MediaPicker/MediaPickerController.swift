public class MediaPickerController: UIViewController, PermissionControllerDelegate {

  let cart = Cart()
  var pagesController: PagesController?
  
  var pagesBottomContraint: NSLayoutConstraint?
  var pagesBottomActiveKeyboardContraint: NSLayoutConstraint?

  public override var shouldAutorotate: Bool {
    return true
  }

  public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
    return [.portrait, .portraitUpsideDown]
  }

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

  func makePagesController() -> PagesController? {
    guard Permission.Photos.status == .authorized else {
      return nil
    }

    let tabsToShow = [Config.GalleryTab.libraryTab, Config.GalleryTab.cameraTab, Config.GalleryTab.audioTab]

    let controllers: [UIViewController] = tabsToShow.compactMap { tab in
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
    ctrl.title = "CAMERA"
    return ctrl
  }

  func createAudioController() -> UIViewController? {
    guard Permission.Microphone.status == .authorized else {
      return nil
    }

    let ctrl = AudioController(cart: self.cart)
    ctrl.title = "AUDIO"
    return ctrl
  }

  func createLibraryController() -> LibraryController {
    let ctrl = LibraryController(cart: cart)
    ctrl.title = "LIBRARY"
    return ctrl
  }


  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()
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
    
    let ntCenter = NotificationCenter.default
    ntCenter.addObserver(self, selector: #selector(keyboardWillBeShown(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    ntCenter.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
  }

  @objc func keyboardWillBeShown(note: Notification) {
    let userInfo = note.userInfo
    let keyboardFrame = userInfo?[UIWindow.keyboardFrameEndUserInfoKey] as! CGRect
    self.pagesBottomContraint?.isActive = false
    if self.pagesBottomActiveKeyboardContraint == nil {
      pagesBottomActiveKeyboardContraint = pagesController?.view.g_pin(on: .bottom, constant: keyboardFrame.height)
    }
    self.pagesBottomActiveKeyboardContraint?.isActive = true
  }
  
  @objc func keyboardWillBeHidden(note: Notification) {
    self.pagesBottomActiveKeyboardContraint?.isActive = false
    if self.pagesBottomContraint == nil {
      pagesBottomContraint = pagesController?.view.g_pin(on: .bottom)
    }
    self.pagesBottomContraint?.isActive = true
  }
  
  func setup() {
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        strongSelf.dismiss(animated: true, completion: nil)
      }
    }

    EventHub.shared.doneWithMedia = { [weak self] in
//      if let strongSelf = self {
//
//      }
    }
    
    EventHub.shared.executeCustomAction = { guid in
      if let item = self.cart.getItem(by: guid) {
        if item.type == .Image {
          let image = item as! Image
          image.resolve(completion: { (uiImage) in
            let photoEditor = PhotoEditorController(image: uiImage!)
//            photoEditor.photoEditorDelegate = self
//            photoEditor.image = uiImage
            self.present(photoEditor, animated: true, completion: nil)
          })
        }
      }
    }
    
    EventHub.shared.selfDeleteFromCart = { guid in
      self.cart.remove(guidToRemove: guid)
    }
  }
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
  public func doneEditing(image: UIImage, selfCtrl: PhotoEditorViewController, editedSomething: Bool) {
    
  }
  
  public func canceledEditing() {
    
  }
}

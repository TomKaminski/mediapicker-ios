public class MediaPickerController: UIViewController, PermissionControllerDelegate {

  let cart = Cart()
  
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
        return createCameraController(title: "CAMERA")
      } else if tab == .audioTab {
        return createAudioController(title: "AUDIO")
      }
      return nil
    }

    guard !controllers.isEmpty else {
      return nil
    }

    let controller = PagesController(controllers: controllers)
    let useCamera = Permission.Camera.status == .authorized
    controller.selectedIndex = useCamera ? 1 : 0

    return controller
  }

  func createCameraController(title: String) -> UIViewController? {
    guard Permission.Camera.status == .authorized else {
      return nil
    }

    let ctrl = UIViewController()
    ctrl.title = title
    return ctrl
  }

  func createAudioController(title: String) -> UIViewController? {
    guard Permission.Microphone.status == .authorized else {
      return nil
    }

    let ctrl = UIViewController()
    ctrl.title = title
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

    if let pagesController = makePagesController() {
      addChildController(pagesController)
    } else {
      let permissionController = makePermissionController()
      addChildController(permissionController)
    }
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
  }
}

public class MediaPickerController: UIViewController, PermissionControllerDelegate {

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
    guard Permission.Photos.status == .authorized && Permission.Camera.status == .authorized && Permission.Microphone.status == .authorized else {
      return nil
    }

    let controllers = [
      createLibraryController(),
      temporaryChildCtrlGen(title: "CAMERA"),
      temporaryChildCtrlGen(title: "AUDIO")
    ]

    guard !controllers.isEmpty else {
      return nil
    }

    let controller = PagesController(controllers: controllers)
    return controller
  }
  
  func temporaryChildCtrlGen(title: String) -> UIViewController {
    let ctrl = UIViewController()
    ctrl.title = title
    return ctrl
  }
  
  func createLibraryController() -> LibraryController {
    let ctrl = LibraryController()
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

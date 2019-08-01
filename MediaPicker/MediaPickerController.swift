public class MediaPickerController: UIViewController, PermissionControllerDelegate {

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
    
    self.navigationController?.setNavigationBarHidden(true, animated: false)

    //setup()

    if let pagesController = makePagesController() {
      addChildController(pagesController)
    } else {
      let permissionController = makePermissionController()
      addChildController(permissionController)
    }
  }

  public override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  public override var prefersStatusBarHidden: Bool {
    return true
  }
}

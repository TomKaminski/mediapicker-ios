class PermissionController: UIViewController {
  let once = Once()

  weak var delegate: PermissionControllerDelegate?
  
  let permissionView = PermissionView()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(permissionView)
    permissionView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
    permissionView.g_pinEdges()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    once.run { self.check() }
  }
  
  func check() {
    if Permission.Photos.status == .notDetermined {
      Permission.Photos.request { [weak self] in
        self?.check()
      }
      return
    } else if Permission.Camera.status == .notDetermined {
      Permission.Camera.request { [weak self] in
        self?.check()
      }
      return
    } else if Permission.Microphone.status == .notDetermined {
      Permission.Microphone.request { [weak self] in
        self?.check()
      }
      return
    }
    
    DispatchQueue.main.async {
      self.delegate?.permissionControllerDidFinish(self, closeTapped: false)
    }
  }
  
  @objc func closeButtonTouched(_ button: UIButton) {
    DispatchQueue.main.async {
      self.delegate?.permissionControllerDidFinish(self, closeTapped: true)
    }
  }
}

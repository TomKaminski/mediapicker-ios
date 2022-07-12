class PermissionController: UIViewController {
  let once = Once()

  weak var delegate: PermissionControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    once.run { self.check() }
  }
    
  func setup() {
    let permissionView = PermissionView()
    view.addSubview(permissionView)
    permissionView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
    permissionView.settingButton.addTarget(self, action: #selector(settingButtonTouched(_:)), for: .touchUpInside)
    permissionView.g_pinEdges()
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
    
  @objc func settingButtonTouched(_ button: UIButton) {
    DispatchQueue.main.async {
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
      }
    }
  }
  
  @objc func closeButtonTouched(_ button: UIButton) {
    DispatchQueue.main.async {
      self.delegate?.permissionControllerDidFinish(self, closeTapped: true)
    }
  }
}

class PermissionController: UIViewController {
  weak var delegate: PermissionControllerDelegate?
  
  lazy var permissionView: PermissionView = self.makePermissionView()

  let once = Once()

  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    once.run {
      self.check()
    }
  }
  
  // MARK: - Setup
  
  func setup() {
    view.addSubview(permissionView)
    permissionView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)),
                                         for: .touchUpInside)
    permissionView.settingButton.addTarget(self, action: #selector(settingButtonTouched(_:)),
                                           for: .touchUpInside)
    permissionView.g_pinEdges()
  }

  // MARK: - Logic
  
  func check() {
    if Permission.Photos.status == .notDetermined {
      Permission.Photos.request { [weak self] in
        self?.check()
      }
      
      return
    }
    
    if Permission.Camera.status == .notDetermined {
      Permission.Camera.request { [weak self] in
        self?.check()
      }
      
      return
    }
    
    if Permission.Microphone.status == .notDetermined {
      Permission.Microphone.request { [weak self] in
        self?.check()
      }
      
      return
    }
    
    DispatchQueue.main.async {
      self.delegate?.permissionControllerDidFinish(self, closeTapped: false)
    }
  }
  
  // MARK: - Action
  
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
  
  // MARK: - Controls
  
  func makePermissionView() -> PermissionView {
    let view = PermissionView()
    
    return view
  }
}

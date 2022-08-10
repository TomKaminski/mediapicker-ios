class MissingPermissionController: UIViewController {
  var permissionView: PermissionCenterView!
  
  let titleSuffix: String
  
  init(titleSuffix: String) {
    self.titleSuffix = titleSuffix
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    permissionView = PermissionCenterView(titleText: "\(MediaPickerConfig.shared.translationKeys.goToSettingsKey.g_localize(fallback: "No access to")) \(titleSuffix)", labelText: MediaPickerConfig.shared.translationKeys.goToSettingsKey.g_localize(fallback: "Enabling privacy permission in system settings will trigger app reload. Please save all of your unsaved work."))
    view.addSubview(permissionView)
    permissionView.g_pinEdges()
  }
}

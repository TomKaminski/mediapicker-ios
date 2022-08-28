public class PreviewController: UIViewController, MediaPreviewToolbarDelegate {
  weak var itemsControllerDelegate: PreviewItemsControllerDelegate?
  
  var items = [String: CartItemProtocol]()
  
  let initialItemGuid: String
  
  lazy var topToolbarView = makeTopToolbarView()
  
  public init(initialItemGuid: String) {
    self.initialItemGuid = initialItemGuid
    super.init(nibName: nil, bundle: nil)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MediaPickerConfig.shared.colors.black
    
    self.items = itemsControllerDelegate?.getItems() ?? [:]
    
    addSubviews()
    setupConstraints()
  }
  
  internal func setupConstraints() {
    NSLayoutConstraint.activate([
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topToolbarView.heightAnchor.constraint(equalToConstant: 40),
      topToolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    ])
  }
  
  func addSubviews() {
    view.addSubview(topToolbarView)
  }
  
  func onBackTap() {
    self.dismiss(animated: true)
  }
  
  func onLabelTap() {

  }
  
  private func makeTopToolbarView() -> MediaPreviewToolbar {
    let view = MediaPreviewToolbar()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

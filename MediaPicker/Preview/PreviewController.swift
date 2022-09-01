public class PreviewController: UIViewController, MediaPreviewToolbarDelegate, BottomViewCartDelegate, PhotoEditorControllerDelegate, MediaRenameControllerDelegate {
  weak var itemsControllerDelegate: PreviewItemsControllerDelegate?
  
  var items = [String: CartItemProtocol]()
  
  var selectedItemGuid: String {
    didSet {
      reloadUI()
    }
  }
  
  lazy var topToolbarView = makeTopToolbarView()
  lazy var cartView: CartCollectionView = makeCartView()
  lazy var fakeBottomSpacer: UIView = makeFakeBottomSpacer()
  
  public weak var parentPhotoEditorDelegate: PhotoEditorControllerDelegate?
  public weak var parentRenameDelegate: MediaRenameControllerDelegate?
  
  public init(initialItemGuid: String) {
    self.selectedItemGuid = initialItemGuid
    super.init(nibName: nil, bundle: nil)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
//    view.backgroundColor = MediaPickerConfig.shared.colors.black
    view.backgroundColor = .white
    
    self.items = itemsControllerDelegate?.getItems() ?? [:]
    
    addSubviews()
    setupConstraints()
    reloadUI()
  }
  
  internal func setupConstraints() {
    NSLayoutConstraint.activate([
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topToolbarView.heightAnchor.constraint(equalToConstant: 40 + (UIApplication.shared.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top ?? 0)),
      topToolbarView.topAnchor.constraint(equalTo: view.topAnchor),
      
      fakeBottomSpacer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      fakeBottomSpacer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      fakeBottomSpacer.heightAnchor.constraint(equalToConstant: (UIApplication.shared.windows.first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 0)),
      fakeBottomSpacer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      cartView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      cartView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      cartView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.shared.bottomView.height),
      cartView.bottomAnchor.constraint(equalTo: fakeBottomSpacer.topAnchor),
    ])
  }
  
  func addSubviews() {
    view.addSubview(topToolbarView)
    view.addSubview(cartView)
    view.addSubview(fakeBottomSpacer)
  }
  
  private func makeTopToolbarView() -> MediaPreviewToolbar {
    let view = MediaPreviewToolbar()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }
  
  func makeCartView() -> CartCollectionView {
    let cartView = CartCollectionView(frame: .zero, cartItems: items)
    cartView.bottomViewCartDelegate = self
    cartView.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    cartView.translatesAutoresizingMaskIntoConstraints = false
    return cartView
  }
  
  func makeFakeBottomSpacer() -> UIView {
    let view = UIView()
    view.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  
  //ACTIONS
  
  func closeCartView() {
    
  }
  
  func onItemDelete(guid: String) {
    
  }
  
  func onItemTap(guid: String) {
    selectedItemGuid = guid
  }
  
  func onBackTap() {
    self.dismiss(animated: true)
  }
  
  func onLabelTap() {

  }
  
  func onEditTap() {
    if let item = items[selectedItemGuid] {
      if item.type == .Image && MediaPickerConfig.shared.camera.allowPhotoEdit {
        let image = item as! Image
        image.resolve(completion: { (uiImage) in
          let photoEditor = PhotoEditorController(image: uiImage!, guid: item.guid)
          photoEditor.modalPresentationStyle = .overFullScreen
          photoEditor.customFileName = image.customFileName
          photoEditor.delegate = self
          photoEditor.renameDelegate = self
          self.present(photoEditor, animated: true, completion: {
            self.reloadUI()
          })
        })
      }
    }
  }
  
  private func canEdit(itemType: CartItemType) -> Bool {
    switch itemType {
      case .Image:
        return MediaPickerConfig.shared.camera.allowPhotoEdit
      default:
        return false
    }
  }
  
  private func toggleUiOnSelectionChange(item: CartItemProtocol) {
    topToolbarView.canEditCurrentItem = canEdit(itemType: item.type)
    topToolbarView.fileNameLabel.text = item.customFileName
    
    cartView.refreshSubView()
  }
  
  private func reloadUI() {
    if let item = items[selectedItemGuid] {
      toggleUiOnSelectionChange(item: item)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func renameMediaFile(guid: String, newFileName: String) {
    parentRenameDelegate?.renameMediaFile(guid: guid, newFileName: newFileName)
    
    if let item = items[guid] {
      cartView.addItem(item: item)
    }
  }
  
  public func editMediaFile(image: UIImage, fileName: String, guid: String, editedSomething: Bool) {
    parentPhotoEditorDelegate?.editMediaFile(image: image, fileName: fileName, guid: guid, editedSomething: editedSomething)
    
    if let item = items[guid] {
      cartView.removeItem(item: item)
      cartView.addItem(item: item)
    }
  }
}

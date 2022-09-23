protocol PreviewItemsControllerDelegate: AnyObject {
  func getItems() -> [String: CartItemProtocol]
  func removeItem(guid: String)
  func replaceItem(oldGuid: String, newItemGuid: String, newItem: CartItemProtocol)
}

public class PreviewController: UIViewController, MediaPreviewToolbarDelegate, BottomViewCartDelegate, PhotoEditorControllerDelegate, MediaRenameControllerDelegate, GalleryFloatingButtonTapDelegate {
  weak var itemsControllerDelegate: PreviewItemsControllerDelegate?
  
  var items = [String: CartItemProtocol]()
  
  var selectedItemGuid: String {
    didSet {
      reloadUI()
    }
  }
  
  lazy var topToolbarView = makeTopToolbarView()
  lazy var cartView = makeCartView()
  lazy var fakeBottomSpacer = makeFakeBottomSpacer()
  lazy var saveButton = makeSaveButton()

  
  public weak var parentPhotoEditorDelegate: PhotoEditorControllerDelegate?
  public weak var parentRenameDelegate: MediaRenameControllerDelegate?
  
  var previewController: AssetPreviewItemController!
  
  public init(initialItemGuid: String) {
    self.selectedItemGuid = initialItemGuid
    super.init(nibName: nil, bundle: nil)
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MediaPickerConfig.shared.colors.black
    
    self.items = itemsControllerDelegate?.getItems() ?? [:]
    
    previewController = AssetPreviewItemController(previewedItem: items[selectedItemGuid]!)
        
    self.addChild(previewController)
    view.addSubview(previewController.view)
    previewController.view.translatesAutoresizingMaskIntoConstraints = false
    previewController.didMove(toParent: self)
    
    addSubviews()
    
    setupConstraints()
    reloadUI()
    
    let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
    leftSwipeGestureRecognizer.direction = .left
    let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
    rightSwipeGestureRecognizer.direction = .right
    
    self.view.addGestureRecognizer(leftSwipeGestureRecognizer)
    self.view.addGestureRecognizer(rightSwipeGestureRecognizer)
  }
  
  private func performNavigation(isNext: Bool) {
    let sorted = items.sorted(by: { $0.value.dateAdded < $1.value.dateAdded })
    let indexOfSelectedGuid = sorted.firstIndex { keyVal in
      return keyVal.key == selectedItemGuid
    }
    
    guard let indexOfSelectedGuid, indexOfSelectedGuid != (isNext ? items.count - 1 : 0) else {
      return
    }
    
    let newGuid = sorted[indexOfSelectedGuid + (isNext ? 1 : -1)].key

    previewController.view.fade(visible: false)
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
      self.selectedItemGuid = newGuid
      self.previewController.view.fade(visible: true)
    }
  }
  
  //SHOW NEXT ELEMENT
  @objc private func didSwipeLeft() {
    performNavigation(isNext: true)
  }
  
  //SHOW PREVIOUS ELEMENT
  @objc private func didSwipeRight() {
    performNavigation(isNext: false)
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
      
      previewController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
      previewController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      previewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      previewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      
      saveButton.bottomAnchor.constraint(equalTo: cartView.topAnchor, constant: -8),
      saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8)
    ])
  }
  
  func addSubviews() {
    view.addSubview(topToolbarView)
    view.addSubview(cartView)
    view.addSubview(fakeBottomSpacer)
    view.addSubview(saveButton)
  }
  
  private func makeTopToolbarView() -> MediaPreviewToolbar {
    let view = MediaPreviewToolbar()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }
  
  private func makeCartView() -> CartCollectionView {
    let cartView = CartCollectionView(frame: .zero, cartItems: items)
    cartView.bottomViewCartDelegate = self
    cartView.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    cartView.translatesAutoresizingMaskIntoConstraints = false
    return cartView
  }
  
  private func makeFakeBottomSpacer() -> UIView {
    let view = UIView()
    view.backgroundColor = MediaPickerConfig.shared.colors.black.withAlphaComponent(0.4)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  private func makeSaveButton() -> GalleryFloatingButton {
    let button = GalleryFloatingButton()
    button.tapDelegate = self
    button.imageView.image = MediaPickerConfig.shared.bottomView.saveIcon

    return button
  }
  
  
  //ACTIONS

  public func tapped() {
    self.dismiss(animated: true) {
      EventHub.shared.doneWithMediaPicker?()
    }
  }
  
  func closeCartView() {
    
  }
  
  func onItemDelete(guid: String) {
    let title = MediaPickerConfig.shared.translationKeys.deleteElementKey.g_localize(fallback: "Delete element")
    let message = MediaPickerConfig.shared.translationKeys.deleteElementDescriptionKey.g_localize(fallback: "Are you sure you want to delete?")
    let deleteBtnText = MediaPickerConfig.shared.translationKeys.deleteKey.g_localize(fallback: "Delete")
    let cancelBtnText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let dialogBuilder = MediaPickerConfig.shared.dialogBuilder, let controller = dialogBuilder(title, message, [
      (cancelBtnText, "cancel", nil),
      (deleteBtnText, "delete", {
        if let parentController = self.presentingViewController as? MediaPickerController {
          parentController.cart.remove(guidToRemove: guid)
          self.itemRemoved(guid: guid)
        }
      })
    ]) {
      self.present(controller, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: deleteBtnText, style: .destructive, handler: { _ in
        if let parentController = self.presentingViewController as? MediaPickerController {
          parentController.cart.remove(guidToRemove: guid)
          self.itemRemoved(guid: guid)
        }
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func onItemTap(guid: String) {
    selectedItemGuid = guid
  }
  
  func onBackTap() {
    self.dismiss(animated: true)
  }
  
  func onLabelTap() {
    if let item = items[selectedItemGuid] {
      presentRenameAlert(guid: selectedItemGuid, baseFilename: FileNameComposer.getFileName(), initialFilename: item.customFileName)
    }
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
  }
  
  private func reloadUI() {
    if let item = items[selectedItemGuid] {
      toggleUiOnSelectionChange(item: item)
      previewController.changePreviewedItem(previewedItem: item)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public func renameMediaFile(guid: String, newFileName: String) {
    parentRenameDelegate?.renameMediaFile(guid: guid, newFileName: newFileName)
  }
  
  public func editMediaFile(image: UIImage, fileName: String, guid: String, editedSomething: Bool) {
    parentPhotoEditorDelegate?.editMediaFile(image: image, fileName: fileName, guid: guid, editedSomething: editedSomething)
  }
  
  public func itemUpdated(item: CartItemProtocol) {
    items.updateValue(item, forKey: item.guid)
    cartView.addItem(item: item)
    reloadUI()
  }
  
  public func itemRemoved(guid: String) {
    if let item = items[guid] {
      cartView.removeItem(item: item)
      items.removeValue(forKey: guid)
      
      if (items.isEmpty) {
        self.dismiss(animated: true)
      } else {
        selectedItemGuid = items.first!.key
        reloadUI()
      }
    }
  }
  
  func presentRenameAlert(guid: String, baseFilename: String, initialFilename: String) {
    let renameText = MediaPickerConfig.shared.translationKeys.renameKey.g_localize(fallback: "Rename")
    let cancelText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let textDialogBuilder = MediaPickerConfig.shared.textDialogBuilder, let controller = textDialogBuilder(renameText, nil, initialFilename, [
      (cancelText, "cancel", nil),
      (renameText, "standard", { inputValue in
        self.parentRenameDelegate?.renameMediaFile(guid: guid, newFileName: inputValue ?? baseFilename)
      })
    ]) {
      self.present(controller, animated: true)
    } else {
      let alertController = UIAlertController(title: renameText, message: nil, preferredStyle: .alert)
      
      alertController.addTextField { (textField) in
        textField.text = initialFilename
        textField.clearButtonMode = .always
      }
      
      alertController.addAction(UIAlertAction(title: cancelText, style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: renameText, style: .default, handler: { _ in
        let textField = alertController.textFields![0]
        let newFileName = textField.text?.isEmpty == false ? textField.text! : baseFilename
        self.parentRenameDelegate?.renameMediaFile(guid: guid, newFileName: newFileName)
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
}

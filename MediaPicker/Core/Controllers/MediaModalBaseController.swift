public class MediaModalBaseController: UIViewController, CartButtonDelegate, CircularButtonConformance, BottomToolbarViewControllerDelegate {
  func closeCartView() {}
  
  func onItemDelete(guid: String) {
    guard let mediaPickerDelegate = mediaPickerControllerDelegate else {
      return
    }
    
    let alertController = UIAlertController(title: MediaPickerConfig.instance.translationKeys.deleteElementKey.g_localize(fallback: "Delete element"), message: MediaPickerConfig.instance.translationKeys.deleteElementDescriptionKey.g_localize(fallback: "Are you sure you want to delete?"), preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.deleteKey.g_localize(fallback: "Delete"), style: .destructive, handler: { _ in
      mediaPickerDelegate.onModalItemRemove(guid: guid)
      if MediaPickerConfig.instance.bottomView.cart.selectedGuid == guid {
        self.dismiss(animated: true, completion: nil)
        EventHub.shared.modalDismissed?(false)
      } else {
        self.bottomToolbarView.setup()
        let values = Array(mediaPickerDelegate.cartItems.values)
        self.cartButton.reload(values)
      }
     }))
    alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel"), style: .cancel, handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
  
  weak var mediaPickerControllerDelegate: BottomViewCartItemsDelegate?

  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  lazy var cartButton: StackView = StackView()

  lazy var addPhotoButton: CircularBorderButton = self.makeCircularButton(with: "addPhotoIcon")
  var bottomToolbarConstraint: NSLayoutConstraint!
  
  var customFileName: String?
  
  var newlyTaken: Bool = true
  
  public override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.black
    
    addSubviews()
    
    cartButton.delegate = self
    cartButton.isHidden = MediaPickerConfig.instance.bottomView.cart.maxItems == 1
    
    bottomToolbarView.controllerDelegate = self
    bottomToolbarView.delegate = mediaPickerControllerDelegate
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.isHidden = MediaPickerConfig.instance.bottomView.cart.maxItems == 1
    addPhotoButton.addTarget(self, action: #selector(onAddNextTap), for: .touchUpInside)
    
    setupConstraints()
    
    bottomToolbarView.lastFileName = self.customFileName
    
    setNeedsStatusBarAppearanceUpdate()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    if let mediaPickerDelegate = mediaPickerControllerDelegate {
      self.cartButton.reload(Array(mediaPickerDelegate.cartItems.values.sorted(by: { item1, item2 in
        return item1.dateAdded < item2.dateAdded
      })))
    }
  }
  
  internal func addSubviews() {
    self.view.addSubview(bottomToolbarView)
    self.view.addSubview(addPhotoButton)
    self.view.addSubview(cartButton)
  }
  
  @objc func onAddNextTap() {
    EventHub.shared.modalDismissed?(true)
    customOnAddNexTap(doneWithMediaTapped: false)
  }
  
  public func updateNewlyTaken() {
    fatalError()
  }
  
  internal func customOnAddNexTap(doneWithMediaTapped: Bool) {
    fatalError()
  }
  
  func cartButtonTapped() {
    self.cartButton.cartOpened = !self.cartButton.cartOpened
    self.bottomToolbarView.cartOpened = self.cartButton.cartOpened
  }
  
  func presentDiscardElementAlert() {
    let alertController = UIAlertController(title: MediaPickerConfig.instance.translationKeys.discardElementKey.g_localize(fallback: "Discard element"), message: MediaPickerConfig.instance.translationKeys.discardElementDescriptionKey.g_localize(fallback: "Are you sure you want to discard?"), preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.discardKey.g_localize(fallback: "Discard"), style: .destructive, handler: { _ in
      EventHub.shared.modalDismissed?(false)
      self.dismiss(animated: true, completion: nil)
    }))
    alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel"), style: .cancel, handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
  
  func presentDiscardChangesAlert() {
    let alertController = UIAlertController(title: MediaPickerConfig.instance.translationKeys.discardChangesKey.g_localize(fallback: "Discard changes"), message: MediaPickerConfig.instance.translationKeys.discardChangesDescriptionKey.g_localize(fallback: "Are you sure you want to discard changes?"), preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.discardKey.g_localize(fallback: "Discard"), style: .destructive, handler: { _ in
      EventHub.shared.modalDismissed?(false)
      self.dismiss(animated: true, completion: nil)
    }))
    alertController.addAction(UIAlertAction(title: MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel"), style: .cancel, handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
  
  func onBackButtonTap() {
    if newlyTaken {
      presentDiscardElementAlert()
    } else {
      EventHub.shared.modalDismissed?(false)
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  internal func setupConstraints() {
    bottomToolbarConstraint = self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    
    Constraint.on(constraints: [
      self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.bottomToolbarConstraint,
      self.bottomToolbarView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.photoEditor.bottomToolbarHeight),
      
      self.addPhotoButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
      self.addPhotoButton.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor, constant: -8),
      
      cartButton.centerYAnchor.constraint(equalTo: addPhotoButton.centerYAnchor),
      cartButton.trailingAnchor.constraint(equalTo: addPhotoButton.leadingAnchor, constant: MediaPickerConfig.instance.bottomView.cartButton.rightMargin),
      cartButton.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.bottomView.cartButton.size),
      cartButton.widthAnchor.constraint(equalToConstant: MediaPickerConfig.instance.bottomView.cartButton.size)
    ])
  }
  
  internal func setupBottomConstraintConstant(_ endFrame: CGRect?) {
    if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
      self.bottomToolbarConstraint?.constant = 0.0
      self.bottomToolbarView.saveButton?.isHidden = false
    } else {
      self.bottomToolbarConstraint?.constant = -(endFrame?.size.height ?? 0.0)
      self.bottomToolbarView.saveButton?.isHidden = true
    }
  }
  
  @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
      
      setupBottomConstraintConstant(endFrame)
      
      UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {
        self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }

}

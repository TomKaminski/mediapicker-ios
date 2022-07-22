public class MediaModalBaseController: UIViewController, CartButtonDelegate, CircularButtonConformance, BottomToolbarViewControllerDelegate {
  func closeCartView() {}
  
  func onItemDelete(guid: String) {
    guard let mediaPickerDelegate = mediaPickerControllerDelegate else {
      return
    }
    
    let title = MediaPickerConfig.instance.translationKeys.deleteElementKey.g_localize(fallback: "Delete element")
    let message = MediaPickerConfig.instance.translationKeys.deleteElementDescriptionKey.g_localize(fallback: "Are you sure you want to delete?")
    let deleteBtnText = MediaPickerConfig.instance.translationKeys.deleteKey.g_localize(fallback: "Delete")
    let cancelBtnText = MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let dialogBuilder = MediaPickerConfig.instance.dialogBuilder, let controller = dialogBuilder(title, message, [
      (deleteBtnText, "delete", {
        mediaPickerDelegate.onModalItemRemove(guid: guid)
        if MediaPickerConfig.instance.bottomView.cart.selectedGuid == guid {
          self.dismiss(animated: true, completion: nil)
          EventHub.shared.modalDismissed?(false)
        } else {
          self.bottomToolbarView.setup()
          let values = Array(mediaPickerDelegate.cartItems.values)
          self.cartButton.reload(values)
        }
      }),
      (cancelBtnText, "cancel", nil)
    ]) {
      self.present(controller, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: deleteBtnText, style: .destructive, handler: { _ in
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
      alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  weak var mediaPickerControllerDelegate: BottomViewCartItemsDelegate?

  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  lazy var cartButton: StackView = StackView()

  lazy var addPhotoButton: CircularBorderButton = self.makeCircularButton(with: "Back")
  var bottomToolbarConstraint: NSLayoutConstraint!
  
  var customFileName: String?
  var cartOpened = false
  var newlyTaken: Bool = true

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.black
    
    addSubviews()
    
    cartButton.delegate = self
    cartButton.isHidden = MediaPickerConfig.instance.bottomView.cart.maxItems == 1
    cartButton.translatesAutoresizingMaskIntoConstraints = false
    
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
    cartOpened = !cartOpened
    //TODO: Animate??
  }
  
  func presentDiscardElementAlert() {
    let title = MediaPickerConfig.instance.translationKeys.discardElementKey.g_localize(fallback: "Discard element")
    let message = MediaPickerConfig.instance.translationKeys.discardElementDescriptionKey.g_localize(fallback: "Are you sure you want to discard?")
    let discardBtnText = MediaPickerConfig.instance.translationKeys.discardKey.g_localize(fallback: "Discard")
    let cancelBtnText = MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let dialogBuilder = MediaPickerConfig.instance.dialogBuilder, let controller = dialogBuilder(title, message, [
      (discardBtnText, "delete", {
        EventHub.shared.modalDismissed?(false)
        self.dismiss(animated: true, completion: nil)
      }),
      (cancelBtnText, "cancel", nil)
    ]) {
      self.present(controller, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: discardBtnText, style: .destructive, handler: { _ in
        EventHub.shared.modalDismissed?(false)
        self.dismiss(animated: true, completion: nil)
      }))
      alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func presentDiscardChangesAlert() {
    let title = MediaPickerConfig.instance.translationKeys.discardChangesKey.g_localize(fallback: "Discard changes")
    let message = MediaPickerConfig.instance.translationKeys.discardChangesDescriptionKey.g_localize(fallback: "Are you sure you want to discard changes?")
    let discardBtnText = MediaPickerConfig.instance.translationKeys.discardKey.g_localize(fallback: "Discard")
    let cancelBtnText = MediaPickerConfig.instance.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let dialogBuilder = MediaPickerConfig.instance.dialogBuilder, let controller = dialogBuilder(title, message, [
      (discardBtnText, "delete", {
        EventHub.shared.modalDismissed?(false)
        self.dismiss(animated: true, completion: nil)
      }),
      (cancelBtnText, "cancel", nil)
    ]) {
      self.present(controller, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: discardBtnText, style: .destructive, handler: { _ in
        EventHub.shared.modalDismissed?(false)
        self.dismiss(animated: true, completion: nil)
      }))
      alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    }
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
    
    self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    self.bottomToolbarConstraint.isActive = true
    self.bottomToolbarView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.photoEditor.bottomToolbarHeight).isActive = true
    
    self.addPhotoButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12).isActive = true
    self.addPhotoButton.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor, constant: -8).isActive = true
    
    cartButton.centerYAnchor.constraint(equalTo: addPhotoButton.centerYAnchor).isActive = true
    cartButton.trailingAnchor.constraint(equalTo: addPhotoButton.leadingAnchor, constant: -16).isActive = true
    cartButton.heightAnchor.constraint(equalToConstant: 56).isActive = true
    cartButton.widthAnchor.constraint(equalToConstant: 56).isActive = true
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

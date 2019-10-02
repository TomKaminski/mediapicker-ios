public class MediaModalBaseController: UIViewController, CartButtonDelegate, CircularButtonConformance, BottomToolbarViewControllerDelegate {
  func closeCartView() {}
  
  func onItemDelete(guid: String) {
    let alertController = UIAlertController(title: "Discard element", message: "Are you sure you want to discard current element?", preferredStyle: .alert)
     alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
      self.mediaPickerControllerDelegate?.onModalItemRemove(guid: guid)
      if Config.BottomView.Cart.selectedGuid == guid {
        self.dismiss(animated: true, completion: nil)
        EventHub.shared.modalDismissed?()
      } else {
        self.bottomToolbarView.setup()
        self.cartButton.updateCartItemsLabel(self.mediaPickerControllerDelegate?.itemsInCart ?? 0, self.cartButton.cartOpened)
      }
     }))
     alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    self.present(alertController, animated: true, completion: nil)
  }
  
  weak var mediaPickerControllerDelegate: BottomViewCartItemsDelegate?

  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  lazy var cartButton: CartButton = CartButton()

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
    bottomToolbarView.controllerDelegate = self
    bottomToolbarView.delegate = mediaPickerControllerDelegate
    
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    
    self.cartButton.updateCartItemsLabel(mediaPickerControllerDelegate?.itemsInCart ?? 0)
    addPhotoButton.addTarget(self, action: #selector(onAddNextTap), for: .touchUpInside)
    
    setupConstraints()
    
    bottomToolbarView.lastFileName = self.customFileName
    
    setNeedsStatusBarAppearanceUpdate()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  
  internal func addSubviews() {
    self.view.addSubview(bottomToolbarView)
    self.view.addSubview(addPhotoButton)
    self.view.addSubview(cartButton)
  }
  
  @objc func onAddNextTap() {
    EventHub.shared.modalDismissed?()
    customOnAddNexTap()
  }
  
  internal func customOnAddNexTap() {
    fatalError()
  }
  
  func cartButtonTapped() {
    self.cartButton.cartOpened = !self.cartButton.cartOpened
    self.bottomToolbarView.cartOpened = self.cartButton.cartOpened
  }
  
  func onBackButtonTap() {
    if newlyTaken {
      let alertController = UIAlertController(title: "Discard element", message: "Are you sure you want to discard current element?", preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: "Discard", style: .destructive, handler: { _ in
        EventHub.shared.modalDismissed?()
        self.dismiss(animated: true, completion: nil)
      }))
      alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      self.present(alertController, animated: true, completion: nil)
    } else {
      EventHub.shared.modalDismissed?()
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  internal func setupConstraints() {
    bottomToolbarConstraint = self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    
    Constraint.on(constraints: [
      self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.bottomToolbarConstraint,
      self.bottomToolbarView.heightAnchor.constraint(equalToConstant: Config.PhotoEditor.bottomToolbarHeight),
      
      self.addPhotoButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
      self.addPhotoButton.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor, constant: -8),
      
      cartButton.centerYAnchor.constraint(equalTo: addPhotoButton.centerYAnchor),
      cartButton.trailingAnchor.constraint(equalTo: addPhotoButton.leadingAnchor, constant: Config.BottomView.CartButton.rightMargin),
      cartButton.heightAnchor.constraint(equalToConstant: Config.BottomView.CartButton.size),
      cartButton.widthAnchor.constraint(equalToConstant: Config.BottomView.CartButton.size)
    ])
  }
  
  @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
      
      if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
        self.bottomToolbarConstraint?.constant = 0.0
      } else {
        self.bottomToolbarConstraint?.constant = -(endFrame?.size.height ?? 0.0)
      }
      
      UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {
        self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }

}

import QuickLook

class AudioPreviewController: UIViewController, QLPreviewControllerDelegate, QLPreviewControllerDataSource, CartButtonDelegate {
  
  weak var mediaPickerControllerDelegate: BottomViewCartItemsDelegate?
  
  func cartButtonTapped() {
    self.cartButton.cartOpened = !self.cartButton.cartOpened
  }
  
  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  lazy var cartButton: CartButton = CartButton()

  lazy var addPhotoButton: CircularBorderButton = self.makeCircularButton(with: "addPhotoIcon")
  var bottomToolbarConstraint: NSLayoutConstraint!
  
  var previewCtrl: QLPreviewController!
  
  let audio: Audio
  
  init(audio: Audio) {
    self.audio = audio
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
    
    self.addPreviewChild()
    self.view.addSubview(bottomToolbarView)
    self.view.addSubview(addPhotoButton)
    self.view.addSubview(cartButton)
    
    cartButton.delegate = self
    
    self.bottomToolbarView.backButton.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
    
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    previewCtrl.view.translatesAutoresizingMaskIntoConstraints = false
    setupConstraints()
    
    self.cartButton.updateCartItemsLabel(mediaPickerControllerDelegate?.itemsInCart ?? 0)
    
    addPhotoButton.addTarget(self, action: #selector(saveAndAddAnotherMedia), for: .touchUpInside)
    
    self.view.backgroundColor = UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
    
    self.bottomToolbarView.filenameInput.text = audio.customFileName
  }
  
  @objc private func saveAndAddAnotherMedia() {
    addOrUpdateCartItem()
    self.dismiss(animated: true, completion: nil)
  }
  
  private func addOrUpdateCartItem() {
    audio.customFileName = self.bottomToolbarView.filenameInput.text
    mediaPickerControllerDelegate?.addUpdateCartItem(item: audio)
  }
  
  private func setupConstraints() {
    bottomToolbarConstraint = self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    
    Constraint.on(constraints: [
      previewCtrl.view.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor),
      previewCtrl.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      previewCtrl.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      
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
    
    if #available(iOS 11.0, *) {
      previewCtrl.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      previewCtrl.view.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
    }
  }
  
  private func addPreviewChild() {
    previewCtrl = QLPreviewController()
    previewCtrl.dataSource = self
    previewCtrl.delegate = self
    
    addChild(previewCtrl)
    view.addSubview(previewCtrl.view)
    previewCtrl.didMove(toParent: self)
  }
  
  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return 1
  }
  
  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    if QLPreviewController.canPreview(audio.audioFile.url as NSURL) {
      return audio.audioFile.url as NSURL
    } else {
      return NSURL()
    }
  }
  
  @objc private func onBackPressed() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func makeCircularButton(with imageName: String) -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerBundle.image(imageName), for: .normal)
    
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.widthAnchor.constraint(equalToConstant: Config.PhotoEditor.editorCircularButtonSize).isActive = true
    btn.heightAnchor.constraint(equalToConstant: Config.PhotoEditor.editorCircularButtonSize).isActive = true
    
    return btn
  }
}

extension AudioPreviewController {
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
      
      UIView.animate(withDuration: duration,
                     delay: TimeInterval(0),
                     options: animationCurve,
                     animations: { self.view.layoutIfNeeded() },
                     completion: nil)
    }
  }
}

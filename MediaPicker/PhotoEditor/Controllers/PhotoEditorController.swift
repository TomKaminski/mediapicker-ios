public final class PhotoEditorController: MediaModalBaseController, TopToolbarViewDelegate, ColorSelectedDelegate {
  
  // ----------------
  // MARK: Properties
  // ----------------

  private let originalImage: UIImage
  public let originalImageGuid: String

  lazy var topToolbarView = makeTopToolbarView()
  
  var canvasImageViewWidthConstraint: NSLayoutConstraint!
  var canvasImageViewHeightConstraint: NSLayoutConstraint!

  var canvasImageViewTopConstraint: NSLayoutConstraint!
  var canvasImageViewBottomConstraint: NSLayoutConstraint!
  
  lazy var imageView = UIImageView()
  lazy var canvasView = UIView()
  lazy var canvasImageView = UIImageView()
  
  var drawColor = UIColor.red
  var textColor = UIColor.white
  var swiped = false
  var lastPoint: CGPoint!
  var lastPanPoint: CGPoint?

  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  var isTyping = false
  
  var editedSomething = false
  
  public var photoEditorDelegate: PhotoEditorDelegate?
  
  init(image: UIImage, guid: String, newlyTaken: Bool) {
    self.originalImage = image
    self.originalImageGuid = guid
    super.init(nibName: nil, bundle: nil)
    self.newlyTaken = newlyTaken
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  
  // ----------------
  // MARK: Controller cycles
  // ----------------
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.topToolbarView.editorViewDelegate = self
    self.setImageView(image: self.originalImage)
    self.bottomToolbarView.lastFileName = customFileName
  }
  
  public override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    
  }
  
  func setImageView(image: UIImage) {
    imageView.image = image
  }
  
  // ----------------
  // MARK: MediaModalBaseController overrides
  // ----------------
  
  override func addSubviews() {
    view.addSubview(canvasView)
    view.addSubview(topToolbarView)
    
    super.addSubviews()
    
    canvasView.addSubview(imageView)
    canvasView.addSubview(canvasImageView)
        
    imageView.contentMode = .scaleAspectFit
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    rebuildCanvasConstraints()
  }
  
  private func rebuildCanvasConstraints() {
    let fixedSize = imageView.contentClippingRect
    canvasImageViewHeightConstraint = self.canvasView.heightAnchor.constraint(lessThanOrEqualToConstant: fixedSize.height)
    canvasImageViewWidthConstraint.constant = fixedSize.width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : fixedSize.width
    
    NSLayoutConstraint.deactivate([canvasImageViewTopConstraint, canvasImageViewBottomConstraint])
    NSLayoutConstraint.activate([canvasImageViewHeightConstraint, self.canvasView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -15)])
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasImageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    
    canvasImageViewWidthConstraint = self.canvasView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
    
    canvasImageViewTopConstraint = self.canvasView.topAnchor.constraint(equalTo: self.topToolbarView.bottomAnchor)
    canvasImageViewBottomConstraint = self.canvasView.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor)
    
    NSLayoutConstraint.activate([
      self.topToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.topToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.topToolbarView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.photoEditor.topToolbarHeight),
      
      self.canvasView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      canvasImageViewTopConstraint,
      canvasImageViewBottomConstraint,
      canvasImageViewWidthConstraint,
      
      self.imageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
      self.imageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
      self.imageView.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
      self.imageView.bottomAnchor.constraint(equalTo: self.canvasView.bottomAnchor),
      
      self.canvasImageView.topAnchor.constraint(equalTo: self.canvasView.topAnchor),
      self.canvasImageView.bottomAnchor.constraint(equalTo: self.canvasView.bottomAnchor),
      self.canvasImageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
      self.canvasImageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
    ])
    
    if #available(iOS 11, *) {
      topToolbarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      topToolbarView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
  }
  
  override func customOnAddNexTap(doneWithMediaTapped: Bool) {
    let img = self.canvasView.toImage()
    
    var customFileName = FileNameComposer.getImageFileName()
    if let fileNameFromInput = self.bottomToolbarView.filenameInput?.text, !fileNameFromInput.isEmpty {
      customFileName = fileNameFromInput
    } else if let lastFileName = self.bottomToolbarView.lastFileName, !lastFileName.isEmpty {
      customFileName = lastFileName
    }
    
    photoEditorDelegate?.doneEditing(image: img, customFileName: customFileName, selfCtrl: self, editedSomething: editedSomething, doneWithMedia: doneWithMediaTapped)
  }
  
  public override func updateNewlyTaken() {
    customOnAddNexTap(doneWithMediaTapped: false)
  }
  
  private func makeTopToolbarView() -> TopToolbarView {
    let view = TopToolbarView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  override func onBackButtonTap() {
    if newlyTaken {
      presentDiscardElementAlert()
    } else if editedSomething {
      presentDiscardChangesAlert()
    } else {
      EventHub.shared.modalDismissed?(false)
      self.dismiss(animated: true, completion: nil)
    }
  }

  // ----------------
  // MARK: TopToolbarViewDelegate
  // ----------------
  
  func textButtonTapped(_ sender: Any) {
    isTyping = true
    let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    
    
    setupTextView(textView)
    self.canvasImageView.addSubview(textView)
    addGestures(view: textView)
    self.bottomToolbarConstraint?.constant = 0.0
    textView.becomeFirstResponder()
  }
  
  func clearButtonTapped(_ sender: Any) {
    canvasImageView.image = nil
    for subview in canvasImageView.subviews {
      subview.removeFromSuperview()
    }
    editedSomething = false
  }
  
  fileprivate func addGestures(view: UIView) {
    view.isUserInteractionEnabled = true

    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(PhotoEditorController.panGesture))
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 1
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(PhotoEditorController.pinchGesture))
    pinchGesture.delegate = self
    view.addGestureRecognizer(pinchGesture)

    let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(PhotoEditorController.rotationGesture))
    rotationGestureRecognizer.delegate = self
    view.addGestureRecognizer(rotationGestureRecognizer)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorController.tapGesture))
    view.addGestureRecognizer(tapGesture)
  }
  
  fileprivate func setupTextView(_ textView: UITextView) {
    textView.textAlignment = .center
    textView.font = MediaPickerConfig.instance.photoEditor.textFont
    textView.textColor = textColor
    textView.layer.shadowColor = UIColor.black.cgColor
    textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
    textView.layer.shadowOpacity = 0.2
    textView.layer.shadowRadius = 1.0
    textView.layer.backgroundColor = UIColor.clear.cgColor
    textView.autocorrectionType = .no
    textView.isScrollEnabled = false
    textView.delegate = self
    textView.returnKeyType = .done
  }
  
  // ----------------
  // MARK: ColorSelectedDelegate
  // ----------------
  
  func didSelectColor(color: UIColor) {
     self.drawColor = color
     if activeTextView != nil {
       activeTextView?.textColor = color
       textColor = color
     }
   }
  
  override func setupBottomConstraintConstant(_ endFrame: CGRect?) {
    if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
      self.bottomToolbarConstraint?.constant = 0.0
      self.bottomToolbarView.saveButton?.isHidden = false
    } else if !self.isTyping {
      self.bottomToolbarConstraint?.constant = -(endFrame?.size.height ?? 0.0)
      self.bottomToolbarView.saveButton?.isHidden = true
    }
  }
}

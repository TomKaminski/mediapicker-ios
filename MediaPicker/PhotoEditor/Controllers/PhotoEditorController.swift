public final class PhotoEditorController: MediaEditorBaseController, TopToolbarViewDelegate, ColorSelectedDelegate {
  private let originalImage: UIImage
  public let originalImageGuid: String

  lazy var topToolbarView = makeTopToolbarView()
  
  var canvasImageViewWidthConstraint: NSLayoutConstraint!
  var canvasImageViewHeightConstraint: NSLayoutConstraint!
  var canvasViewWidthConstraint: NSLayoutConstraint!
  var canvasViewHeightConstraint: NSLayoutConstraint!
  
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
    
  init(image: UIImage, guid: String, newlyTaken: Bool) {
    self.originalImage = image
    self.originalImageGuid = guid
    super.init(nibName: nil, bundle: nil)
    self.newlyTaken = newlyTaken
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.topToolbarView.editorViewDelegate = self
    self.setImageView(image: self.originalImage)
    self.bottomToolbarView.lastFileName = customFileName
  }
  
  func setImageView(image: UIImage) {
    imageView.image = image
  }
  
  override func addSubviews() {
    view.addSubview(imageView)
    view.addSubview(topToolbarView)
    
    super.addSubviews()
    
    imageView.addSubview(canvasView)
    imageView.addSubview(canvasImageView)
    imageView.contentMode = .scaleAspectFit
  }
  
  public override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    rebuildCanvasConstraints()
  }
  
  private func rebuildCanvasConstraints() {
    let fixedSize = imageView.contentClippingRect
    let height = fixedSize.height
    let width = fixedSize.width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : fixedSize.width
    
    canvasImageViewHeightConstraint.constant = height
    canvasImageViewWidthConstraint.constant = width
    canvasViewHeightConstraint.constant = height
    canvasViewWidthConstraint.constant = width
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasImageView.translatesAutoresizingMaskIntoConstraints = false
    
    canvasImageViewWidthConstraint = canvasImageView.widthAnchor.constraint(equalToConstant: 100)
    canvasImageViewHeightConstraint = canvasImageView.heightAnchor.constraint(equalToConstant: 100)
    canvasViewWidthConstraint = canvasView.widthAnchor.constraint(equalToConstant: 100)
    canvasViewHeightConstraint = canvasView.heightAnchor.constraint(equalToConstant: 100)
    
    NSLayoutConstraint.activate([
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topToolbarView.heightAnchor.constraint(equalToConstant: 80),
      topToolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      imageView.topAnchor.constraint(equalTo: topToolbarView.bottomAnchor, constant: -40),
      imageView.bottomAnchor.constraint(equalTo: bottomToolbarView.topAnchor),
      
      canvasView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
      canvasView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
      canvasViewHeightConstraint,
      canvasViewWidthConstraint,
      
      canvasImageView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
      canvasImageView.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
      canvasImageViewHeightConstraint,
      canvasImageViewWidthConstraint,
    ])
  }
  
  override func onSave() {
    let img = self.canvasView.toImage()
    
    var customFileName = FileNameComposer.getImageFileName()
    if let fileNameFromInput = self.bottomToolbarView.filenameInput?.text, !fileNameFromInput.isEmpty {
      customFileName = fileNameFromInput
    } else if let lastFileName = self.bottomToolbarView.lastFileName, !lastFileName.isEmpty {
      customFileName = lastFileName
    }
    
    doneDelegate?.doneEditingPhoto(image: img, customFileName: customFileName, guid: originalImageGuid, editedSomething: editedSomething)
    dismiss(animated: true, completion: nil)
  }
  
  private func makeTopToolbarView() -> TopToolbarView {
    let view = TopToolbarView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
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
    textView.font = MediaPickerConfig.shared.photoEditor.textFont
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
  
  func didSelectColor(color: UIColor) {
     self.drawColor = color
     if activeTextView != nil {
       activeTextView?.textColor = color
       textColor = color
     }
   }
  
  func onTextTap() {
    isTyping = true
    let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
    
    setupTextView(textView)
    self.canvasImageView.addSubview(textView)
    addGestures(view: textView)
    self.bottomToolbarConstraint?.constant = 0.0
    textView.becomeFirstResponder()
  }
  
  func onClearTap() {
    canvasImageView.image = nil
    for subview in canvasImageView.subviews {
      subview.removeFromSuperview()
    }
    editedSomething = false
  }
  
  override func onBackTap() {
    if editedSomething {
      presentDiscardChangesAlert()
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func onPencilTap() {
    
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
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

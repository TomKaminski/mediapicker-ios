public final class PhotoEditorController: MediaEditorBaseController, TopToolbarViewDelegate, ColorSelectedDelegate, GalleryFloatingButtonTapDelegate {
  private let originalImage: UIImage
  public let originalImageGuid: String

  lazy var topToolbarView = makeTopToolbarView()
  
  var canvasViewWidthConstraint: NSLayoutConstraint!
  var canvasViewHeightConstraint: NSLayoutConstraint!
  var canvasViewTopConstraint: NSLayoutConstraint!
  var canvasViewBottomConstraint: NSLayoutConstraint!

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
  
  weak var delegate: PhotoEditorControllerDelegate?
  
  public func tapped() {
    let img = self.canvasView.toImage()
    
    var customFileName = FileNameComposer.getImageFileName()
//    if let fileNameFromInput = self.bottomToolbarView.filenameInput?.text, !fileNameFromInput.isEmpty {
//      customFileName = fileNameFromInput
//    } else if let lastFileName = self.bottomToolbarView.lastFileName, !lastFileName.isEmpty {
//      customFileName = lastFileName
//    }
    
    delegate?.editMediaFile(image: img, customFileName: customFileName, guid: originalImageGuid, editedSomething: editedSomething)
    dismiss(animated: true, completion: nil)
  }
    
  init(image: UIImage, guid: String, newlyTaken: Bool) {
    self.originalImage = image
    self.originalImageGuid = guid
    super.init(nibName: nil, bundle: nil)
    self.newlyTaken = newlyTaken
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    self.saveButton.tapDelegate = self
    self.topToolbarView.editorViewDelegate = self
    self.topToolbarView.fileNameLabel.text = customFileName
    self.setImageView(image: self.originalImage)
  }
  
  func setImageView(image: UIImage) {
    imageView.image = image
  }
  
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
    canvasViewHeightConstraint = self.canvasView.heightAnchor.constraint(lessThanOrEqualToConstant: fixedSize.height)
    canvasViewWidthConstraint.constant = fixedSize.width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : fixedSize.width
    NSLayoutConstraint.deactivate([canvasViewBottomConstraint])
    NSLayoutConstraint.activate([canvasViewHeightConstraint])
  }

  override func setupConstraints() {
    super.setupConstraints()
    
    imageView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasImageView.translatesAutoresizingMaskIntoConstraints = false

    canvasViewWidthConstraint = self.canvasView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
    canvasViewTopConstraint = self.canvasView.topAnchor.constraint(equalTo: self.topToolbarView.bottomAnchor, constant: -40)
    canvasViewBottomConstraint = self.canvasView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)

    NSLayoutConstraint.activate([
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topToolbarView.heightAnchor.constraint(equalToConstant: 80),
      topToolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      self.canvasView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
      canvasViewTopConstraint,
      canvasViewBottomConstraint,
      canvasViewWidthConstraint,
      
      imageView.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
      imageView.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor),
      imageView.widthAnchor.constraint(equalTo: canvasView.widthAnchor),
      imageView.heightAnchor.constraint(equalTo: canvasView.heightAnchor),
      
      canvasImageView.centerXAnchor.constraint(equalTo: canvasView.centerXAnchor),
      canvasImageView.centerYAnchor.constraint(equalTo: canvasView.centerYAnchor),
      canvasImageView.widthAnchor.constraint(equalTo: canvasView.widthAnchor),
      canvasImageView.heightAnchor.constraint(equalTo: canvasView.heightAnchor),
    ])
  }
  
  private func makeTopToolbarView() -> PhotoEditorToolbar {
    let view = PhotoEditorToolbar()
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
    tapGesture.delegate = self
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
    let textView = UITextView(frame: CGRect(x: 0, y: UIScreen.main.bounds.width/3, width: UIScreen.main.bounds.width, height: 30))
    
    setupTextView(textView)
    canvasImageView.addSubview(textView)
    addGestures(view: textView)
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
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

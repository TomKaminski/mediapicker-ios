public final class PhotoEditorController: MediaModalBaseController, TopToolbarViewDelegate {
  private let originalImage: UIImage
  public let originalImageGuid: String

  lazy var topToolbarView = makeTopToolbarView()
  
  var imageViewHeightConstraint: NSLayoutConstraint!
  var canvasViewWidthConstraint: NSLayoutConstraint!

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
  
  override public func viewDidLoad() {
    super.viewDidLoad()

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    self.topToolbarView.editorViewDelegate = self
    self.setImageView(image: self.originalImage)
    self.bottomToolbarView.lastFileName = customFileName
  }
  
  override func customOnAddNexTap() {
    let img = self.canvasView.toImage()
    
    //TODO: Check if really edited sth..!!
    photoEditorDelegate?.doneEditing(image: img, customFileName: self.bottomToolbarView.filenameInput?.text ?? self.bottomToolbarView.lastFileName ?? FileNameComposer.getImageFileName(), selfCtrl: self, editedSomething: true)
  }
  
  private func makeTopToolbarView() -> TopToolbarView {
    let view = TopToolbarView()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  private func makeBottomToolbarView() -> BottomToolbarView {
    let view = BottomToolbarView()

    view.lastFileName = customFileName
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  override func addSubviews() {
    view.addSubview(canvasView)
    view.addSubview(topToolbarView)
    
    super.addSubviews()
    
    canvasView.addSubview(imageView)
    canvasView.addSubview(canvasImageView)
    
    imageView.contentMode = .scaleAspectFit
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasImageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
    
    imageViewHeightConstraint = self.imageView.heightAnchor.constraint(lessThanOrEqualToConstant: 680)

    NSLayoutConstraint.activate([
      self.topToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.topToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.topToolbarView.heightAnchor.constraint(equalToConstant: Config.PhotoEditor.topToolbarHeight),
      
      self.canvasView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.canvasView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.canvasView.topAnchor.constraint(greaterThanOrEqualTo: self.topToolbarView.bottomAnchor),
      self.canvasView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor),
      
      self.imageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
      self.imageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
      self.imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topToolbarView.bottomAnchor),
      self.imageView.bottomAnchor.constraint(lessThanOrEqualTo: self.bottomToolbarView.topAnchor),
      imageViewHeightConstraint,
      
      self.canvasImageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
      self.canvasImageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
      self.canvasImageView.centerYAnchor.constraint(equalTo: self.canvasView.centerYAnchor),
      self.canvasImageView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor),
    ])
    
    if #available(iOS 11, *) {
      topToolbarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      topToolbarView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
  }
  
  //Actions & delegates
  
  func textButtonTapped(_ sender: Any) {
    isTyping = true
    let textView = UITextView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height/4,
                                            width: UIScreen.main.bounds.width, height: 30))
    
    textView.textAlignment = .center
    textView.font = Config.PhotoEditor.textFont
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
    self.canvasImageView.addSubview(textView)
    addGestures(view: textView)
    textView.becomeFirstResponder()
  }
  
  func clearButtonTapped(_ sender: Any) {
    canvasImageView.image = nil
    for subview in canvasImageView.subviews {
      subview.removeFromSuperview()
    }
  }
  
  func doneButtonTapped(_ sender: Any) {
    view.endEditing(true)
    canvasImageView.isUserInteractionEnabled = true
    isTyping = false
  }
  
  private func addGestures(view: UIView) {
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
  
  func setImageView(image: UIImage) {
    imageView.image = image
    let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
    imageViewHeightConstraint.constant = (size?.height)!
  }
}

extension PhotoEditorController: ColorSelectedDelegate {
  func didSelectColor(color: UIColor) {
    self.drawColor = color
    if activeTextView != nil {
      activeTextView?.textColor = color
      textColor = color
    }
  }
}

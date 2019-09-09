public final class PhotoEditorController: UIViewController, TopToolbarViewDelegate {
  func textButtonTapped(_ sender: Any) {
    isTyping = true
    let textView = UITextView(frame: CGRect(x: 0, y: 0,
                                            width: UIScreen.main.bounds.width, height: 30))
    
    textView.textAlignment = .center
    textView.font = UIFont(name: "Helvetica", size: 30)
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
  
  @IBAction func doneButtonTapped(_ sender: Any) {
    view.endEditing(true)
    canvasImageView.isUserInteractionEnabled = true
    isTyping = false
  }
  
  private let originalImage: UIImage
  
  lazy var topToolbarView: TopToolbarView = TopToolbarView()
  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  lazy var addPhotoButton: CircularBorderButton = self.makeCircularButton(with: "addPhotoIcon")
  
  var bottomToolbarConstraint: NSLayoutConstraint!
  var imageViewHeightConstraint: NSLayoutConstraint!

  lazy var imageView: UIImageView = UIImageView()
  lazy var canvasView: UIView = UIView()
  lazy var canvasImageView: UIImageView = UIImageView()
  
  var drawColor = UIColor.red
  var textColor = UIColor.white
  var swiped = false
  var lastPoint: CGPoint!
  var lastPanPoint: CGPoint?

  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  var isTyping = false
  
  func saveAndAddAnotherMedia() {
    self.dismiss(animated: true, completion: nil)
  }
  
  init(image: UIImage) {
    self.originalImage = image
    super.init(nibName: nil, bundle: nil)
  }
  
  private func makeCircularButton(with imageName: String) -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerBundle.image(imageName), for: .normal)
    
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.widthAnchor.constraint(equalToConstant: 40).isActive = true
    btn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    return btn
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .black
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    setup()
    self.topToolbarView.editorViewDelegate = self
    self.setImageView(image: self.originalImage)
  }
  
  private func setup() {
    view.addSubview(topToolbarView)
    view.addSubview(bottomToolbarView)
    view.addSubview(addPhotoButton)
    view.addSubview(canvasView)
    
    canvasView.addSubview(imageView)
    canvasView.addSubview(canvasImageView)
    
    imageView.contentMode = .scaleAspectFit

    topToolbarView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasImageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false

    bottomToolbarConstraint = self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    imageViewHeightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: 680)
    
    NSLayoutConstraint.activate([
      self.topToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.topToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.topToolbarView.heightAnchor.constraint(equalToConstant: 60),
      
      self.canvasView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.canvasView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.canvasView.topAnchor.constraint(equalTo: self.topToolbarView.bottomAnchor),
      self.canvasView.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor),

      self.imageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
      self.imageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
      self.imageView.centerYAnchor.constraint(equalTo: self.canvasView.centerYAnchor),
      imageViewHeightConstraint,
      
      self.canvasImageView.trailingAnchor.constraint(equalTo: self.canvasView.trailingAnchor),
      self.canvasImageView.leadingAnchor.constraint(equalTo: self.canvasView.leadingAnchor),
      self.canvasImageView.centerYAnchor.constraint(equalTo: self.canvasView.centerYAnchor),
      self.canvasImageView.heightAnchor.constraint(equalTo: self.imageView.heightAnchor),
      
      self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.bottomToolbarConstraint,
      self.bottomToolbarView.heightAnchor.constraint(equalToConstant: 120),
      
      self.addPhotoButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
      self.addPhotoButton.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor, constant: -8)
      ])
    
    if #available(iOS 11, *) {
      topToolbarView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      topToolbarView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
  }
  
  func addGestures(view: UIView) {
    //Gestures
    view.isUserInteractionEnabled = true

    let panGesture = UIPanGestureRecognizer(target: self,
                                            action: #selector(PhotoEditorController.panGesture))
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 1
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                action: #selector(PhotoEditorController.pinchGesture))
    pinchGesture.delegate = self
    view.addGestureRecognizer(pinchGesture)

    let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                action: #selector(PhotoEditorController.rotationGesture))
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

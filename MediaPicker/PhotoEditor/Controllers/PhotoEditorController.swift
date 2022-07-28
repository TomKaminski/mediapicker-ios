public final class PhotoEditorController: MediaEditorBaseController, TopToolbarViewDelegate, ColorSelectedDelegate, GalleryFloatingButtonTapDelegate {
  private let originalImage: UIImage
  public let originalImageGuid: String

  lazy var topToolbarView = makeTopToolbarView()
  lazy var brushSlider = makeBrushSlider()
  
  var canvasViewWidthConstraint: NSLayoutConstraint!
  var canvasViewHeightConstraint: NSLayoutConstraint!
  var canvasViewTopConstraint: NSLayoutConstraint!
  var canvasViewBottomConstraint: NSLayoutConstraint!
  var toolbarViewHeightConstraint: NSLayoutConstraint!

  lazy var imageView = UIImageView()
  lazy var canvasView = UIView()
  lazy var canvasImageView = UIImageView()
  
  let saveButton = GalleryFloatingButton()
  
  var drawColor = UIColor.red
  var textColor = UIColor.white
  var swiped = false
  var lastPoint: CGPoint!
  var lastPanPoint: CGPoint?

  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  var isTyping = false
  var isPencilActive = true
  
  var editedSomething = false
  
  public weak var delegate: PhotoEditorControllerDelegate?
  
  public func tapped() {
    let img = self.canvasView.toImage()
    delegate?.editMediaFile(image: img, fileName: customFileName ?? FileNameComposer.getImageFileName(), guid: originalImageGuid, editedSomething: editedSomething)
    dismiss(animated: true, completion: nil)
  }
    
  public init(image: UIImage, guid: String) {
    self.originalImage = image
    self.originalImageGuid = guid
    super.init(nibName: nil, bundle: nil)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    addSubviews()
    setupConstraints()
    
    saveButton.imageView.image = MediaPickerConfig.shared.bottomView.saveIcon
    saveButton.tapDelegate = self
    topToolbarView.delegate = self
    topToolbarView.fileNameLabel.text = customFileName
    setImageView(image: self.originalImage)
  }
  
  func setImageView(image: UIImage) {
    imageView.image = image
  }
  
  func addSubviews() {
    view.addSubview(canvasView)
    view.addSubview(saveButton)
    view.addSubview(topToolbarView)
    view.addSubview(brushSlider)
    sliderValueChanged()
    
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
    canvasViewHeightConstraint = canvasView.heightAnchor.constraint(lessThanOrEqualToConstant: fixedSize.height)
    canvasViewWidthConstraint.constant = fixedSize.width > UIScreen.main.bounds.width ? UIScreen.main.bounds.width : fixedSize.width
    
    NSLayoutConstraint.deactivate([
      canvasViewBottomConstraint,
      canvasViewTopConstraint,
    ])
    NSLayoutConstraint.activate([
      canvasViewHeightConstraint,
      canvasView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    ])
  }

  func setupConstraints() {
    imageView.translatesAutoresizingMaskIntoConstraints = false
    canvasView.translatesAutoresizingMaskIntoConstraints = false
    canvasImageView.translatesAutoresizingMaskIntoConstraints = false

    canvasViewWidthConstraint = self.canvasView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
    canvasViewTopConstraint = self.canvasView.topAnchor.constraint(equalTo: self.topToolbarView.bottomAnchor, constant: -40)
    canvasViewBottomConstraint = self.canvasView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)

    toolbarViewHeightConstraint = self.topToolbarView.heightAnchor.constraint(equalToConstant: 80)
    
    NSLayoutConstraint.activate([
      saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
      
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      toolbarViewHeightConstraint,
      topToolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      canvasView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
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
      
      brushSlider.trailingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100),
      brushSlider.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      brushSlider.widthAnchor.constraint(equalToConstant: 151),
      brushSlider.heightAnchor.constraint(equalToConstant: 25)
    ])
  }
  
  private func makeTopToolbarView() -> PhotoEditorToolbar {
    let view = PhotoEditorToolbar()
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
  
  private func makeBrushSlider() -> UISlider {
    let view = UISlider()
    view.value = 0.2
    view.translatesAutoresizingMaskIntoConstraints = false
    view.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
    view.maximumTrackTintColor = .clear
    view.minimumTrackTintColor = .clear
    view.setMinimumTrackImage(MediaPickerBundle.image("sizePencil"), for: .normal)
    view.setMaximumTrackImage(MediaPickerBundle.image("sizePencil"), for: .normal)
    view.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi/2))
    return view
  }
  
  @objc func sliderValueChanged() {
    DispatchQueue.main.async {
      let targetSize = 10 + (CGFloat(self.brushSlider.value) * 25)
      self.brushSlider.setThumbImage(MediaPickerBundle.image("thumb")?.scalePreservingAspectRatio(targetSize: .init(width: targetSize, height: targetSize)), for: .normal)
    }
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
    textView.font = UIFont.systemFont(ofSize: 24)
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
  
  func onBackTap() {
    if editedSomething {
      presentDiscardChangesAlert()
    } else {
      self.dismiss(animated: true, completion: nil)
    }
  }
  
  func onPencilTap() {
    isPencilActive.toggle()
    if isPencilActive {
      toolbarViewHeightConstraint.constant = 80
      topToolbarView.colorsCollectionView.isHidden = false
      topToolbarView.colorsCollectionView.isUserInteractionEnabled = true
      brushSlider.isHidden = false
      brushSlider.isUserInteractionEnabled = true
      topToolbarView.pencilButton.setImage(MediaPickerBundle.image("Pencil")?.withTintColor(MediaPickerConfig.shared.colors.blue), for: UIControl.State())
    } else {
      toolbarViewHeightConstraint.constant = 40
      topToolbarView.colorsCollectionView.isHidden = true
      topToolbarView.colorsCollectionView.isUserInteractionEnabled = false
      brushSlider.isHidden = true
      brushSlider.isUserInteractionEnabled = false
      topToolbarView.pencilButton.setImage(MediaPickerBundle.image("Pencil")?.withTintColor(.white), for: UIControl.State())
    }
  }
  
  func onLabelTap() {
    self.presentRenameAlert(guid: originalImageGuid, baseFilename: FileNameComposer.getImageFileName())
  }
  
  override func onFilenameChanged() {
    if let customFileName = customFileName {
      self.topToolbarView.fileNameLabel.text = customFileName
    }
  }
  
  func presentDiscardChangesAlert() {
    let title = MediaPickerConfig.shared.translationKeys.discardChangesKey.g_localize(fallback: "Discard changes")
    let message = MediaPickerConfig.shared.translationKeys.discardChangesDescriptionKey.g_localize(fallback: "Are you sure you want to discard changes?")
    let discardBtnText = MediaPickerConfig.shared.translationKeys.discardKey.g_localize(fallback: "Discard")
    let cancelBtnText = MediaPickerConfig.shared.translationKeys.cancelKey.g_localize(fallback: "Cancel")
    
    if let dialogBuilder = MediaPickerConfig.shared.dialogBuilder, let controller = dialogBuilder(title, message, [
      (cancelBtnText, "cancel", nil),
      (discardBtnText, "delete", {
        self.dismiss(animated: true, completion: nil)
      })
    ]) {
      self.present(controller, animated: true, completion: nil)
    } else {
      let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: cancelBtnText, style: .cancel, handler: nil))
      alertController.addAction(UIAlertAction(title: discardBtnText, style: .destructive, handler: { _ in
        self.dismiss(animated: true, completion: nil)
      }))
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

import QuickLook

class AudioPreviewController: MediaModalBaseController, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
  
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
    newlyTaken = audio.newlyTaken
    
    self.bottomToolbarView.lastFileName = audio.customFileName
  }
  
  override func addSubviews() {
    self.addPreviewChild()
    super.addSubviews()
  }
  
  override func customOnAddNexTap() {
    audio.customFileName = self.bottomToolbarView.filenameInput?.text ?? self.bottomToolbarView.lastFileName ?? FileNameComposer.getAudioFileName()
    audio.newlyTaken = false
    mediaPickerControllerDelegate?.addUpdateCartItem(item: audio)
    self.dismiss(animated: true, completion: nil)
  }
  
  internal override func setupConstraints() {
    super.setupConstraints()
    
    Constraint.on(constraints: [
      previewCtrl.view.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor),
      previewCtrl.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      previewCtrl.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
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
    previewCtrl.view.translatesAutoresizingMaskIntoConstraints = false

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
      
      UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: {
        self.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
}

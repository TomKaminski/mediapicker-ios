public class MediaEditorBaseController: UIViewController {
  weak var doneDelegate: MediaEditorControllerDelegate?

  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()
  
  var customFileName: String?
  var newlyTaken: Bool = true
  
  var bottomToolbarConstraint: NSLayoutConstraint!

  override public func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = MediaPickerConfig.shared.colors.black
    addSubviews()
    
    bottomToolbarView.delegate = doneDelegate
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    bottomToolbarView.lastFileName = self.customFileName

    setupConstraints()
    
    setNeedsStatusBarAppearanceUpdate()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  
  func addSubviews() {
    view.addSubview(bottomToolbarView)
  }
  
  internal func onSave() {
    fatalError()
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
  
  func onBackTap() {
    self.dismiss(animated: true, completion: nil)
  }
  
  internal func setupConstraints() {
    bottomToolbarConstraint = self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    
    self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    self.bottomToolbarView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.shared.photoEditor.bottomToolbarHeight).isActive = true
    self.bottomToolbarConstraint.isActive = true
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

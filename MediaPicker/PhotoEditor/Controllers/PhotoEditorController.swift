public final class PhotoEditorController: UIViewController, EditorViewControllerDelegate {
  
  var drawColor = UIColor.red
  var textColor = UIColor.white
  var swiped = false
  var lastPoint: CGPoint!
  var lastPanPoint: CGPoint?
  var lastTextViewTransform: CGAffineTransform?
  var lastTextViewTransCenter: CGPoint?
  var lastTextViewFont: UIFont?
  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  var isTyping = false
  
  var canvasView: UIView {
    return self.editorView.centerView.canvasView
  }
  
  var canvasImageView: UIImageView {
    return self.editorView.centerView.imageView
  }
  
  func saveAndAddAnotherMedia() {
    self.dismiss(animated: true, completion: nil)
  }
  
  lazy var editorView: EditorView = self.makeEditorView()
  
  private let originalImage: UIImage
  
  init(image: UIImage) {
    self.originalImage = image
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func makeEditorView() -> EditorView {
    let editorView = EditorView(frame: CGRect.zero)
    editorView.controllerDelegate = self
    return editorView
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    setup()
    editorView.setImage(self.originalImage)
  }
  
  private func setup() {
    view.addSubview(editorView)
    
    editorView.translatesAutoresizingMaskIntoConstraints = false
    editorView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    editorView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    editorView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    
    if #available(iOS 11, *) {
      editorView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      editorView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    }
  }
}

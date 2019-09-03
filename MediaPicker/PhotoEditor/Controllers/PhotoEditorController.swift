public final class PhotoEditorController: UIViewController {
  lazy var editorView: EditorView = self.makeEditorView()
  
  private func makeEditorView() -> EditorView {
    return EditorView(frame: CGRect.zero)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    setup()
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

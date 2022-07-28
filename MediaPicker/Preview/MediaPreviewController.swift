import QuickLook

public class MediaPreviewController: MediaEditorBaseController, QLPreviewControllerDelegate, QLPreviewControllerDataSource, MediaPreviewToolbarDelegate {
  var previewCtrl: QLPreviewController!
  
  lazy var topToolbarView = makeTopToolbarView()
  
  let url: URL
  let guid: String
    
  public init(url: URL, guid: String, customFileName: String) {
    self.url = url
    self.guid = guid
    
    super.init(nibName: nil, bundle: nil)
    
    self.customFileName = customFileName
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    
    addSubviews()
    setupConstraints()
    
    topToolbarView.fileNameLabel.text = customFileName
  }
  
  func addSubviews() {
    addPreviewChild()
    view.addSubview(topToolbarView)
  }
  
  internal func setupConstraints() {
    NSLayoutConstraint.activate([
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topToolbarView.heightAnchor.constraint(equalToConstant: 40),
      topToolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
    
      previewCtrl.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      previewCtrl.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      previewCtrl.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      previewCtrl.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor)
    ])
  }
  
  private func addPreviewChild() {
    previewCtrl = QLPreviewController()
    previewCtrl.dataSource = self
    previewCtrl.delegate = self
    previewCtrl.view.translatesAutoresizingMaskIntoConstraints = false
    previewCtrl.view.backgroundColor = MediaPickerConfig.shared.colors.black

    addChild(previewCtrl)
    view.addSubview(previewCtrl.view)
    previewCtrl.didMove(toParent: self)
  }
  
  public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return 1
  }
  
  public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    if QLPreviewController.canPreview(url as NSURL) {
      return url as NSURL
    } else {
      return NSURL()
    }
  }
  
  private func makeTopToolbarView() -> MediaPreviewToolbar {
    let view = MediaPreviewToolbar()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }
  
  func onBackTap() {
    self.dismiss(animated: true)
  }
  
  func onLabelTap() {
    presentRenameAlert(guid: guid, baseFilename: FileNameComposer.getFileName())
  }
  
  override func onFilenameChanged() {
    if let customFileName = customFileName {
      self.topToolbarView.fileNameLabel.text = customFileName
    }
  }
}

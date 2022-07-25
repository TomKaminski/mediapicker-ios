import QuickLook

class AudioPreviewController: MediaEditorBaseController, QLPreviewControllerDelegate, QLPreviewControllerDataSource {
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
  
  private func addOrUpdateItem() {
    if let fileNameFromInput = self.bottomToolbarView.filenameInput?.text, !fileNameFromInput.isEmpty {
      audio.customFileName = fileNameFromInput
    } else if let lastFileName = self.bottomToolbarView.lastFileName, !lastFileName.isEmpty {
      audio.customFileName = lastFileName
    } else {
      audio.customFileName = FileNameComposer.getAudioFileName()
    }
    
    audio.newlyTaken = false
    doneDelegate?.onSaveTapped(item: audio)
  }
  
  override func onSave() {
    addOrUpdateItem()
    self.dismiss(animated: true, completion: nil)
  }
  
  internal override func setupConstraints() {
    super.setupConstraints()
    
    previewCtrl.view.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor).isActive = true
    previewCtrl.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    previewCtrl.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
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

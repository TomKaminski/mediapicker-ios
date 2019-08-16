class AudioPreviewController: UIViewController {
  
  let takenAudioUrl: URL
  
  init(takenAudioUrl: URL) {
    self.takenAudioUrl = takenAudioUrl
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = UIColor.init(red: 152/255, green: 152/255, blue: 152/255, alpha: 1)
  }
}

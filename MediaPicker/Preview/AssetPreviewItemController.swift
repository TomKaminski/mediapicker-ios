import ImageScrollView
import AVFAudio

class AssetPreviewItemController: UIViewController {
  var previewedItem: CartItemProtocol
  
  var previewView: UIView?
  
  public init(previewedItem: CartItemProtocol) {
    self.previewedItem = previewedItem
    super.init(nibName: nil, bundle: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = MediaPickerConfig.shared.colors.black
    
    loadByItemType()
  }
  
  public func changePreviewedItem(previewedItem: CartItemProtocol) {
    self.previewedItem = previewedItem
    loadByItemType()
  }
  
  func loadByItemType() {
    if let image = previewedItem as? Image {
      previewImage(image: image)
    } else if let video = previewedItem as? Video {
      previewVideo(video: video)
    } else if let audio = previewedItem as? Audio {
      previewAudio(audio: audio)
    }
  }
  
  private func removePreviewView() {
    previewView?.removeFromSuperview()
    previewView = nil
  }
  
  private func previewImage(image: Image) {
    image.resolve { uiImage in
      guard let uiImage = uiImage else {
        return
      }
      
      if let oldPinchableImageView = self.previewView as? ImageScrollView {
        oldPinchableImageView.display(image: uiImage)
      } else {
        self.removePreviewView()
        let pinchableImage = ImageScrollView()
        self.view.addSubview(pinchableImage)
        pinchableImage.setup()
        pinchableImage.display(image: uiImage)
        pinchableImage.g_pinEdges()
        self.previewView = pinchableImage
      }
    }
  }
  
  private func previewVideo(video: Video) {
    
  }
  
  private func previewAudio(audio: Audio) {
    self.removePreviewView()

    let previewView = AudioPreviewView(audio: audio)
    self.view.addSubview(previewView)
    previewView.g_pinEdges()
    self.previewView = previewView
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class AudioPreviewView: UIView, AVAudioPlayerDelegate {
  let image = UIImageView(image: MediaPickerBundle.image("musicIcon")!)
  
  let backgroundWaveForm = WaveformImageView(frame: .zero)
  let foregroundWaveForm = WaveformImageView(frame: .zero)
  
  let playPauseButton = UIImageView()
    
  let player: AVAudioPlayer!
  var playerTimer: Timer?
  
  public init(audio: Audio) {
    player = try! AVAudioPlayer(contentsOf: audio.audioFile.url)
    
    super.init(frame: .zero)
    
    backgroundColor = .white
    
    addSubview(image)
    image.contentMode = .scaleAspectFit
    image.translatesAutoresizingMaskIntoConstraints = false
    image.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    image.heightAnchor.constraint(equalToConstant: 120).isActive = true
    image.widthAnchor.constraint(equalToConstant: 120).isActive = true
    image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -120).isActive = true

    
    addSubview(backgroundWaveForm)
    backgroundWaveForm.translatesAutoresizingMaskIntoConstraints = false
    backgroundWaveForm.waveformAudioURL = audio.audioFile.url
    backgroundWaveForm.configuration = Waveform.Configuration(size: CGSize(width: 160, height: 50), backgroundColor: .white, style: .striped(.init(color: MediaPickerConfig.shared.colors.lightGray, width: 3, spacing: 3, lineCap: .round)), dampening: nil, position: .middle, verticalScalingFactor: 1.4, shouldAntialias: true)
    backgroundWaveForm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    backgroundWaveForm.heightAnchor.constraint(equalToConstant: 50).isActive = true
    backgroundWaveForm.widthAnchor.constraint(equalToConstant: 160).isActive = true
    backgroundWaveForm.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
    
    addSubview(foregroundWaveForm)
    foregroundWaveForm.translatesAutoresizingMaskIntoConstraints = false
    foregroundWaveForm.waveformAudioURL = audio.audioFile.url
    foregroundWaveForm.configuration = Waveform.Configuration(size: CGSize(width: 160, height: 50), backgroundColor: .white, style: .striped(.init(color: MediaPickerConfig.shared.colors.black, width: 3, spacing: 3, lineCap: .round)), dampening: nil, position: .middle, verticalScalingFactor: 1.4, shouldAntialias: true)
    foregroundWaveForm.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    foregroundWaveForm.heightAnchor.constraint(equalToConstant: 50).isActive = true
    foregroundWaveForm.widthAnchor.constraint(equalToConstant: 160).isActive = true
    foregroundWaveForm.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
    updateProgressWaveform(0)
    
    addSubview(playPauseButton)
    playPauseButton.image = UIImage(systemName: "play.circle")
    playPauseButton.contentMode = .scaleAspectFit
    playPauseButton.isUserInteractionEnabled = true
    playPauseButton.layer.cornerRadius = 30
    playPauseButton.translatesAutoresizingMaskIntoConstraints = false
    playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    playPauseButton.topAnchor.constraint(equalTo: backgroundWaveForm.bottomAnchor, constant: 20).isActive = true
    playPauseButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
    playPauseButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
    playPauseButton.tintColor = MediaPickerConfig.shared.colors.black
    
    let playStopButtonGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playButtonTouched))
    playPauseButton.addGestureRecognizer(playStopButtonGestureRecognizer)
    
    player.delegate = self
  }
  
  deinit {
    playerTimer?.invalidate()
    playerTimer = nil
  }
  
  @objc private func playButtonTouched() {
    if player.isPlaying {
      player.stop()
      playerTimer?.invalidate()
      playerTimer = nil
      updateProgressWaveform(0)
    } else {
      player.play()
      playerTimer = Timer.scheduledTimer(
        timeInterval: 0.015, target: self, selector: #selector(playerTimerFired), userInfo: nil, repeats: true)
    }
    togglePlayStopButton(isPlaying: player.isPlaying)
  }
  
  func togglePlayStopButton(isPlaying: Bool) {
    let icon = isPlaying ? UIImage(systemName: "stop.circle") : UIImage(systemName: "play.circle")
    
    UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionCrossDissolve, animations: {
      self.playPauseButton.image = icon
    }, completion: nil)
  }
  
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    togglePlayStopButton(isPlaying: player.isPlaying)
  }
  
  func updateProgressWaveform(_ progress: Double) {
    let fullRect = foregroundWaveForm.bounds
    let newWidth = Double(fullRect.size.width) * progress

    let maskLayer = CAShapeLayer()
    let maskRect = CGRect(x: 0.0, y: 0.0, width: newWidth, height: Double(fullRect.size.height))

    let path = CGPath(rect: maskRect, transform: nil)
    maskLayer.path = path

    foregroundWaveForm.layer.mask = maskLayer
  }
  
  @objc private func playerTimerFired() {
    updateProgressWaveform(player.currentTime/player.duration)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

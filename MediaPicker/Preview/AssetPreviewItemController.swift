import ImageScrollView
import AVFAudio
import Photos
import PhotosUI

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
    if let audioPreviewView = previewView as? AudioPreviewView {
      audioPreviewView.player.stop()
      audioPreviewView.playerTimer?.invalidate()
      audioPreviewView.playerTimer = nil
    } else if let videoPreviewView = previewView as? VideoPreviewView {
      PHPhotoLibrary.shared().unregisterChangeObserver(videoPreviewView)
    }
    
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
        pinchableImage.g_pinEdges()
        pinchableImage.setup()
        pinchableImage.display(image: uiImage)
        self.previewView = pinchableImage
      }
    }
  }
  
  private func previewVideo(video: Video) {
    self.removePreviewView()

    let previewView = VideoPreviewView(video: video)
    self.view.addSubview(previewView)
    previewView.g_pinEdges()
    self.previewView = previewView
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

class VideoPreviewView: UIView, PHPhotoLibraryChangeObserver {
  lazy var imageView = self.makeImageView()
  lazy var playIcon = self.makePlayIcon()
  
  let video: Video
  
  var assetCollection: PHAssetCollection!
  
  fileprivate var playerLayer: AVPlayerLayer!
  
  init(video: Video) {
    self.video = video
    super.init(frame: .zero)
    PHPhotoLibrary.shared().register(self)
    
    addSubview(imageView)
    addSubview(playIcon)
    
    NSLayoutConstraint.activate([
      imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
      imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
      imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
      imageView.topAnchor.constraint(equalTo: topAnchor),

      playIcon.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
      playIcon.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
      playIcon.heightAnchor.constraint(equalToConstant: 60),
      playIcon.widthAnchor.constraint(equalToConstant: 60),
    ])
    
    setupNotifications()
    updateStaticImage()
  }
  
  var playerPaused = true {
    didSet {
      self.playIcon.isHidden = !self.playerPaused
    }
  }
  
  @objc func play() {
    if playerLayer != nil {
      if playerPaused {
        startPlaying()
      } else {
        stopPlaying()
      }
    } else {
      video.fetchPlayerItem { playerItem in
        DispatchQueue.main.async {
          let player = AVPlayer(playerItem: playerItem)
          let newLayer = AVPlayerLayer(player: player)
          
          newLayer.videoGravity = AVLayerVideoGravity.resizeAspect
          newLayer.frame = self.imageView.layer.bounds
          if let oldLayer = self.playerLayer {
            self.imageView.layer.replaceSublayer(oldLayer, with: newLayer)
          } else {
            self.imageView.layer.addSublayer(newLayer)
          }
          
          self.playerLayer = newLayer
          self.startPlaying()
        }
      }
    }
  }
  
  var targetSize: CGSize {
    let scale = UIScreen.main.scale
    return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
  }
  
  func updateStaticImage() {
    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestImage(for: video.asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
      guard let image = image else {
        return
      }
      self.imageView.isHidden = false
      self.imageView.image = image
    })
  }
  
  @objc private func handleImageTap() {
    play()
  }
  
  private func startPlaying() {
    self.playerLayer?.player?.play()
    playerPaused = false
  }
  
  private func stopPlaying() {
    self.playerLayer?.player?.pause()
    playerPaused = true
  }

  private func setupNotifications() {
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerLayer?.player?.currentItem, queue: .main) { [weak self] _ in
      self?.playerLayer?.player?.seek(to: CMTime.zero)
      self?.playerLayer?.player?.play()
    }
  }
  
  private func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
    return imageView
  }
  
  private func makePlayIcon() -> UIImageView {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(systemName: "play.circle")
    imageView.tintColor = .white
    return imageView
  }
  
  public func photoLibraryDidChange(_ changeInstance: PHChange) {
    DispatchQueue.main.sync {
      guard let details = changeInstance.changeDetails(for: video.asset) else {
        return
      }
      
      video.asset = details.objectAfterChanges ?? details.objectBeforeChanges
      
      if details.assetContentChanged {
        updateStaticImage()
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
      }
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class AudioPreviewView: UIView, AVAudioPlayerDelegate {
  let image = UIImageView(image: MediaPickerBundle.image("audioIcon")!)
  
  let backgroundWaveForm = WaveformImageView(frame: .zero)
  let foregroundWaveForm = WaveformImageView(frame: .zero)
  
  let playPauseButton = UIImageView()
    
  let player: AVAudioPlayer!
  var playerTimer: Timer?
  var waveFormTapRecognizer: UITapGestureRecognizer!
  
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
    backgroundWaveForm.isUserInteractionEnabled = true
    backgroundWaveForm.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
    waveFormTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(waveFormTapped))
    backgroundWaveForm.addGestureRecognizer(waveFormTapRecognizer)
    
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
  
  @objc private func waveFormTapped() {
    if waveFormTapRecognizer.state == .recognized {
      player.stop()
      playerTimer?.invalidate()
      playerTimer = nil
      
      let x = waveFormTapRecognizer.location(in: backgroundWaveForm).x
      let percentageOfX = Double(x/160)
      updateProgressWaveform(percentageOfX)
      
      player.currentTime = player.duration * percentageOfX
      player.play()
      playerTimer = Timer.scheduledTimer(
        timeInterval: 0.015, target: self, selector: #selector(playerTimerFired), userInfo: nil, repeats: true)
      
      togglePlayStopButton(isPlaying: player.isPlaying)
    }
  }
  
  @objc private func playButtonTouched() {
    if player.isPlaying {
      player.stop()
      player.currentTime = 0
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

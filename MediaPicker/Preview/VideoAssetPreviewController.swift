import UIKit
import Photos
import PhotosUI

class VideoAssetPreviewController: MediaEditorBaseController, MediaPreviewToolbarDelegate {
  lazy var imageView = self.makeImageView()
  lazy var playIcon = self.makePlayIcon()
  lazy var topToolbarView = self.makeTopToolbarView()
  
  var video: Video!
  var assetCollection: PHAssetCollection!
  
  var editButton: UIBarButtonItem!
  var playButton: UIBarButtonItem!
    
  var playerPaused = true {
    didSet {
      self.playIcon.isHidden = !self.playerPaused
    }
  }
  
  fileprivate var playerLayer: AVPlayerLayer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addSubviews()
    setupConstraints()
    setupNotifications()

    topToolbarView.fileNameLabel.text = customFileName

    PHPhotoLibrary.shared().register(self)
  }
  
  func addSubviews() {
    view.addSubview(imageView)
    view.addSubview(playIcon)
    view.addSubview(topToolbarView)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    view.layoutIfNeeded()
    updateStaticImage()
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  // ----------------
  // MARK: Interaction
  // ----------------
  
  func onBackTap() {
    self.dismiss(animated: true)
  }
  
  func onLabelTap() {
    self.presentRenameAlert(guid: video.guid, baseFilename: FileNameComposer.getVideoFileName())
  }
  
  override func onFilenameChanged() {
    if let customFileName = customFileName {
      self.topToolbarView.fileNameLabel.text = customFileName
    }
  }
  
  @objc private func handleImageTap() {
    play(self)
  }
  
  @objc func play(_ sender: AnyObject) {
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
  
  // --------------
  // MARK: Image display (video placeholder)
  // --------------

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
  
  // --------------
  // MARK: Private methods
  // --------------
  
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
  
  internal func setupConstraints() {
    NSLayoutConstraint.activate([
      topToolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      topToolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      topToolbarView.heightAnchor.constraint(equalToConstant: 40),
      topToolbarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      
      imageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
      imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),

      playIcon.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor),
      playIcon.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor),
      playIcon.heightAnchor.constraint(equalToConstant: 60),
      playIcon.widthAnchor.constraint(equalToConstant: 60),
    ])
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
    imageView.image = MediaPickerBundle.image("playIcon")
    return imageView
  }
  
  private func makeTopToolbarView() -> MediaPreviewToolbar {
    let view = MediaPreviewToolbar()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.delegate = self
    return view
  }
}

// --------------
// MARK: PHPhotoLibraryChangeObserver
// --------------

extension VideoAssetPreviewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
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
}

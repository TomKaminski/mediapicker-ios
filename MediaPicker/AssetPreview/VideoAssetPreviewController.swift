import UIKit
import Photos
import PhotosUI

class VideoAssetPreviewController: MediaModalBaseController {
  
  // ----------------
  // MARK: Properties
  // ----------------

  lazy var imageView = self.makeImageView()
  lazy var playIcon = self.makePlayIcon()
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
  
  // ----------------
  // MARK: UIViewController Life Cycle
  // ----------------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    newlyTaken = video.newlyTaken

    setupConstraints()
    setupNotifications()

    PHPhotoLibrary.shared().register(self)
  }
  
  override func addSubviews() {
    self.view.addSubview(imageView)
    self.view.addSubview(playIcon)
    super.addSubviews()
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

  override func customOnAddNexTap(doneWithMediaTapped: Bool) {
    addOrUpdateCartItem()
    self.dismiss(animated: true, completion: nil)
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
      let options = PHVideoRequestOptions()
      options.isNetworkAccessAllowed = true
      options.deliveryMode = .automatic
      // Request an AVPlayerItem for the displayed PHAsset.
      // Then configure a layer for playing it.
      PHImageManager.default().requestPlayerItem(forVideo: video.asset, options: options, resultHandler: { playerItem, info in
        DispatchQueue.main.async {
          // Create an AVPlayer and AVPlayerLayer with the AVPlayerItem.
          let player = AVPlayer(playerItem: playerItem)
          
          let newLayer = AVPlayerLayer(player: player)
          
          // Configure the AVPlayerLayer and add it to the view.
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
      })
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
  
  override func updateNewlyTaken() {
    addOrUpdateCartItem()
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
  
  private func addOrUpdateCartItem() {
    if let fileNameFromInput = self.bottomToolbarView.filenameInput?.text, !fileNameFromInput.isEmpty {
      video.customFileName = fileNameFromInput
    } else if let lastFileName = self.bottomToolbarView.lastFileName, !lastFileName.isEmpty {
      video.customFileName = lastFileName
    } else {
      video.customFileName = FileNameComposer.getVideoFileName()
    }
    
    video.newlyTaken = false
    mediaPickerControllerDelegate?.addUpdateCartItem(item: video)
  }

  private func setupNotifications() {
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerLayer?.player?.currentItem, queue: .main) { [weak self] _ in
      self?.playerLayer?.player?.seek(to: CMTime.zero)
      self?.playerLayer?.player?.play()
    }
  }
  
  internal override func setupConstraints() {
    super.setupConstraints()

    imageView.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor).isActive = true
    imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
    imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
    imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true

    playIcon.centerXAnchor.constraint(equalTo: self.imageView.centerXAnchor).isActive = true
    playIcon.centerYAnchor.constraint(equalTo: self.imageView.centerYAnchor).isActive = true
    playIcon.heightAnchor.constraint(equalToConstant: 60).isActive = true
    playIcon.widthAnchor.constraint(equalToConstant: 60).isActive = true
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

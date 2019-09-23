import UIKit
import Photos
import PhotosUI

class VideoAssetPreviewController: UIViewController, CircularButtonConformance {
  
  // ----------------
  // MARK: Properties
  // ----------------

  weak var mediaPickerControllerDelegate: BottomViewCartItemsDelegate?

  lazy var bottomToolbarView = self.makeBottomView()
  lazy var addPhotoButton = self.makeCircularButton(with: "addPhotoIcon")
  lazy var imageView = self.makeImageView()

  var video: Video!
  var assetCollection: PHAssetCollection!
  
  var editButton: UIBarButtonItem!
  var playButton: UIBarButtonItem!
  
  var playerPaused = true
  
  fileprivate var playerLayer: AVPlayerLayer!
    
  var bottomToolbarConstraint: NSLayoutConstraint!
  
  // ----------------
  // MARK: UIViewController Life Cycle
  // ----------------
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    
    self.view.addSubview(imageView)
    self.view.addSubview(bottomToolbarView)
    self.view.addSubview(addPhotoButton)
    
    setupConstraints()
    setupNotifications()

    PHPhotoLibrary.shared().register(self)
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
  
  @objc private func saveAndAddAnotherMedia() {
    addOrUpdateCartItem()
    self.dismiss(animated: true, completion: nil)
  }
  
  @objc private func onBackPressed() {
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
        DispatchQueue.main.sync {
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
    video.customFileName = self.bottomToolbarView.filenameInput.text
    mediaPickerControllerDelegate?.addUpdateCartItem(item: video)
  }

  private func setupNotifications() {
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerLayer?.player?.currentItem, queue: .main) { [weak self] _ in
      self?.playerLayer?.player?.seek(to: CMTime.zero)
      self?.playerLayer?.player?.play()
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
  }
  
  private func setupConstraints() {
    bottomToolbarConstraint = self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
    
    Constraint.on(constraints: [
      imageView.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor),
      imageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      
      self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
      self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
      self.bottomToolbarConstraint,
      self.bottomToolbarView.heightAnchor.constraint(equalToConstant: Config.PhotoEditor.bottomToolbarHeight),
      
      self.addPhotoButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -12),
      self.addPhotoButton.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor, constant: -8)
    ])
    
    if #available(iOS 11.0, *) {
      imageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
    } else {
      imageView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor).isActive = true
    }
  }
  
  private func makeBottomView() -> BottomToolbarView {
    let view = BottomToolbarView()
    
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backButton.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)
    view.filenameInput.text = video.customFileName

    return view
  }
  
  private func makeAddPhotoButton() -> CircularBorderButton {
    let view = self.makeCircularButton(with: "addPhotoIcon")
    view.addTarget(self, action: #selector(saveAndAddAnotherMedia), for: .touchUpInside)
    return view
  }
  
  private func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
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

// --------------
// MARK: Keyboard frame
// --------------

extension VideoAssetPreviewController {
  @objc func keyboardWillChangeFrame(_ notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
      let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
      let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
      let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
      let animationCurve: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
      
      if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
        self.bottomToolbarConstraint?.constant = 0.0
      } else {
        self.bottomToolbarConstraint?.constant = -(endFrame?.size.height ?? 0.0)
      }
      
      self.playerLayer?.removeFromSuperlayer()
      self.playerLayer = nil
      
      UIView.animate(withDuration: duration, delay: TimeInterval(0), options: animationCurve, animations: { self.view.layoutIfNeeded() }, completion: nil)
    }
  }
}

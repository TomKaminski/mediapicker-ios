/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 Implements the view controller that displays a single asset.
 */

import UIKit
import Photos
import PhotosUI

class AudioVideoAssetPreviewController: UIViewController {
  lazy var bottomToolbarView: BottomToolbarView = BottomToolbarView()

  var asset: PHAsset!
  var assetCollection: PHAssetCollection!
  
  var imageView = UIImageView()
  lazy var addPhotoButton: CircularBorderButton = self.makeCircularButton(with: "addPhotoIcon")

  var editButton: UIBarButtonItem!
  var playButton: UIBarButtonItem!
  
  var playerPaused = true
  
  fileprivate var playerLayer: AVPlayerLayer!
  
  fileprivate lazy var formatIdentifier = Bundle.main.bundleIdentifier!
  fileprivate let formatVersion = "1.0"
  fileprivate lazy var ciContext = CIContext()
  
  var bottomToolbarConstraint: NSLayoutConstraint!

  // MARK: UIViewController / Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    imageView.contentMode = .scaleAspectFit
    imageView.isUserInteractionEnabled = true
    imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
    
    self.view.addSubview(imageView)
    self.view.addSubview(bottomToolbarView)
    self.view.addSubview(addPhotoButton)
    
    self.bottomToolbarView.backButton.addTarget(self, action: #selector(onBackPressed), for: .touchUpInside)

    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false
    imageView.translatesAutoresizingMaskIntoConstraints = false
    addPhotoButton.translatesAutoresizingMaskIntoConstraints = false

    setupConstraints()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    PHPhotoLibrary.shared().register(self)
    
    NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: self.playerLayer?.player?.currentItem, queue: .main) { [weak self] _ in
      self?.playerLayer?.player?.seek(to: CMTime.zero)
      self?.playerLayer?.player?.play()
    }
  }
  
  @objc private func onBackPressed() {
    self.dismiss(animated: true, completion: nil)
  }
  
  private func makeCircularButton(with imageName: String) -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    btn.setImage(MediaPickerBundle.image(imageName), for: .normal)
    
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.widthAnchor.constraint(equalToConstant: Config.PhotoEditor.editorCircularButtonSize).isActive = true
    btn.heightAnchor.constraint(equalToConstant: Config.PhotoEditor.editorCircularButtonSize).isActive = true
    
    return btn
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
  
  @objc private func handleImageTap() {
    play(self)
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // Make sure the view layout happens before requesting an image sized to fit the view.
    view.layoutIfNeeded()
    updateStaticImage()
  }
  
  /// - Tag: PlayVideo
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
      PHImageManager.default().requestPlayerItem(forVideo: asset, options: options, resultHandler: { playerItem, info in
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
  
  private func startPlaying() {
    self.playerLayer?.player?.play()
    playerPaused = false
  }
  
  private func stopPlaying() {
    self.playerLayer?.player?.pause()
    playerPaused = true
  }
  
  // MARK: Image display
  
  var targetSize: CGSize {
    let scale = UIScreen.main.scale
    return CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
  }
  
  func updateStaticImage() {
    // Prepare the options to pass when fetching the (photo, or video preview) image.
    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options,
                                          resultHandler: { image, _ in
                                            
                                            // If the request succeeded, show the image view.
                                            guard let image = image else { return }
                                            
                                            // Show the image.
                                            self.imageView.isHidden = false
                                            self.imageView.image = image
    })
  }
}

// MARK: PHPhotoLibraryChangeObserver
extension AudioVideoAssetPreviewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    // The call might come on any background queue. Re-dispatch to the main queue to handle it.
    DispatchQueue.main.sync {
      // Check if there are changes to the displayed asset.
      guard let details = changeInstance.changeDetails(for: asset) else { return }
      
      // Get the updated asset.
      asset = details.objectAfterChanges
      
      // If the asset's content changes, update the image and stop any video playback.
      if details.assetContentChanged {
        updateStaticImage()
        
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
      }
    }
  }
}

extension AudioVideoAssetPreviewController {
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
      
      UIView.animate(withDuration: duration,
                     delay: TimeInterval(0),
                     options: animationCurve,
                     animations: { self.view.layoutIfNeeded() },
                     completion: nil)
    }
  }
}

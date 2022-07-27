import UIKit
import MediaPicker

class ViewController: UIViewController, MediaPickerControllerDelegate {
  @IBOutlet weak var imageView: UIImageView!
  
  func mediaPicker(_ controller: MediaPickerController, didSelectMedia media: [CartItemProtocol]) {
    controller.dismiss(animated: true) {
      let images = media.compactMap { $0 as? Image }
      let audios = media.compactMap { $0 as? Audio }
      let videos = media.compactMap { $0 as? Video }
      
      images.first?.resolve(completion: { uiImage in
        self.imageView.image = uiImage
      })

      let alert = UIAlertController(title: "Media picker finished", message: "Selected images: \(images.count), selected video: \(videos.count), selected audio: \(audios.count)", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func mediaPickerDidCancel(_ controller: MediaPickerController) {
    controller.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onLeftAddTap(_ sender: Any) {
    let picker = MediaPickerController()
    picker.modalPresentationStyle = .overFullScreen
    picker.delegate = self
    
    MediaPickerConfig.shared = MediaPickerConfig()
    MediaPickerConfig.shared.camera.allowPhotoEdit = true
    MediaPickerConfig.shared.audio.includeAudioTab = false
    MediaPickerConfig.shared.camera.recordMode = .photo
    MediaPickerConfig.shared.cart.maxItems = 1
    MediaPickerConfig.shared.videoRecording.allow = false
    
    self.present(picker, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setNeedsStatusBarAppearanceUpdate()
  }

  @IBAction func onTapAdd(_ sender: Any) {
    MediaPickerConfig.shared = MediaPickerConfig()
    MediaPickerConfig.shared.camera.allowPhotoEdit = true
    
    let picker = MediaPickerController()
    picker.modalPresentationStyle = .overFullScreen
    picker.delegate = self
    
    self.present(picker, animated: true, completion: nil)
  }
}


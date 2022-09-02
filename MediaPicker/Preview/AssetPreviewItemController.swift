import ImageScrollView

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
    
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

import UIKit
import Photos

class LibraryController: UIViewController, LibraryTabTopViewDelegate {
  lazy var dropdownController: DropdownController = self.makeDropdownController()
  lazy var gridView: GridView = self.makeGridView()

  var images: [Image] = []
  var videos: [Video] = []

  let library = Library()
  var selectedAlbum: Album?
  let once = Once()

  let cart: Cart

  public required init(cart: Cart) {
    self.cart = cart
    super.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = MediaPickerConfig.shared.colors.black
    cart.delegates.add(self)
    setup()
    pagesController?.topView.libraryDelegate = self
  }

  func setup() {
    view.addSubview(gridView)

    addChild(dropdownController)
    gridView.addSubview(dropdownController.view)
    dropdownController.didMove(toParent: self)

    gridView.g_pinEdges()

    dropdownController.view.g_pin(on: .left)
    dropdownController.view.g_pin(on: .right)
    dropdownController.view.g_pin(on: .height)
    dropdownController.expandedTopConstraint = dropdownController.view.g_pin(on: .top, view: gridView, on: .top, constant: 40 + (UIApplication.shared.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top ?? 0))
    dropdownController.expandedTopConstraint?.isActive = false
    dropdownController.collapsedTopConstraint = dropdownController.view.g_pin(on: .top, on: .bottom)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
    gridView.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))
  }

  func show(album: Album) {
    pagesController?.topView.dropdownButton.updateText(album.collection.localizedTitle ?? "")

    images = album.images
    videos = album.videos

    gridView.collectionView.reloadData()
    gridView.collectionView.scrollToTop()
  }
  
  func onDropdownTap() {
    dropdownController.toggle()
    pagesController?.topView.dropdownButton.toggle(dropdownController.expanding)
  }

  func refreshSelectedAlbum() {
    if let selectedAlbum = selectedAlbum {
      selectedAlbum.reload()
      show(album: selectedAlbum)
    }
  }

  func makeDropdownController() -> DropdownController {
    let controller = DropdownController()
    controller.delegate = self
    return controller
  }

  func makeGridView() -> GridView {
    let view = GridView()
    return view
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}


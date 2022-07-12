import UIKit
import Photos

class LibraryController: UIViewController {
  lazy var dropdownController: DropdownController = self.makeDropdownController()
  lazy var gridView: GridView = self.makeGridView()

  var images: [Image] = []
  var videos: [Video] = []

  let library = Library()
  var selectedAlbum: Album?
  let once = Once()

  let cart: Cart

  // MARK: - Init

  public required init(cart: Cart) {
    self.cart = cart
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.cart.delegates.add(self)
    setup()
  }

  // MARK: - Setup

  func setup() {
    view.backgroundColor = UIColor.black

    view.addSubview(gridView)

    addChild(dropdownController)
    gridView.insertSubview(dropdownController.view, belowSubview: gridView.topView)
    dropdownController.didMove(toParent: self)

    gridView.g_pinEdges()

    dropdownController.view.g_pin(on: .left)
    dropdownController.view.g_pin(on: .right)
    dropdownController.view.g_pin(on: .height, constant: -40) // subtract gridView.topView height

    dropdownController.expandedTopConstraint = dropdownController.view.g_pin(on: .top, view: gridView.topView, on: .bottom, constant: 1)
    dropdownController.expandedTopConstraint?.isActive = false
    dropdownController.collapsedTopConstraint = dropdownController.view.g_pin(on: .top, on: .bottom)

    gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
    gridView.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))
  }

  // MARK: - Action

  @objc func arrowButtonTouched(_ button: ArrowButton) {
    dropdownController.toggle()
    button.toggle(dropdownController.expanding)
  }

  // MARK: - Logic

  func show(album: Album) {
    gridView.arrowButton.updateText(album.collection.localizedTitle ?? "")

    images = album.images
    videos = album.videos

    gridView.collectionView.reloadData()
    gridView.collectionView.scrollToTop()
    gridView.emptyView.isHidden = !images.isEmpty || !videos.isEmpty
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
    view.bottomView.alpha = 0
    return view
  }
}


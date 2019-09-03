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
    view.backgroundColor = UIColor.white

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

  // MARK: - Controls

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

extension LibraryController: PageAware {
  func switchedToState(state: MediaToolbarState) {
    
  }
  
  var initialBottomViewState: MediaToolbarState {
    return .Library
  }

  func pageDidHide() {

  }

  func pageDidShow() {
    once.run {
      library.reload {
        self.gridView.loadingIndicator.stopAnimating()
        self.dropdownController.albums = self.library.albums
        self.dropdownController.tableView.reloadData()

        if let album = self.library.albums.first {
          self.selectedAlbum = album
          self.show(album: album)
        }
      }
    }
  }
}

extension LibraryController: DropdownControllerDelegate {

  func dropdownController(_ controller: DropdownController, didSelect album: Album) {
    selectedAlbum = album
    show(album: album)

    dropdownController.toggle()
    gridView.arrowButton.toggle(controller.expanding)
  }
}

extension LibraryController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count + videos.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: UICollectionViewCell
    if indexPath.row < images.count {
      cell = configureImageCell(collectionView, cellForItemAt: indexPath)
    } else {
      cell = configureVideoCell(collectionView, cellForItemAt: indexPath)
    }

    return cell
  }

  private func configureImageCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
    as! ImageCell
    let nsIndexPath = (indexPath as NSIndexPath)
    let item = images[nsIndexPath.item]

    cell.configure(item)
    configureFrameView(cell, indexPath: indexPath)
    return cell
  }

  private func configureVideoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath)
    as! VideoCell
    let nsIndexPath = (indexPath as NSIndexPath)
    let item = videos[nsIndexPath.item - self.images.count]

    cell.configure(item)
    configureFrameView(cell, indexPath: indexPath)
    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let size = (collectionView.bounds.size.width - (Config.Grid.Dimension.columnCount - 1) * Config.Grid.Dimension.cellSpacing)
    / Config.Grid.Dimension.columnCount
    return CGSize(width: size, height: size)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let newItem = getCartItem(indexPath: indexPath)
    if let itemFromCart = cart.getItem(by: newItem.guid) {
      cart.remove(itemFromCart)
    } else {
      cart.add(newItem)
    }

    configureFrameViews()
  }

  private func getCartItem(indexPath: IndexPath) -> CartItemProtocol {
    if indexPath.row < images.count {
      return images[indexPath.row]
    } else {
      return videos[indexPath.row - self.images.count]
    }
  }

  func configureFrameViews() {
    for case let cell as ImageCell in gridView.collectionView.visibleCells {
      if let indexPath = gridView.collectionView.indexPath(for: cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }

  func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
    let newItem = getCartItem(indexPath: indexPath)
    if cart.getItem(by: newItem.guid) != nil {
      cell.frameView.quickFade()
    } else {
      cell.frameView.alpha = 0
    }
  }

  var pagesController: PagesController {
    return self.parent as! PagesController
  }
}

extension LibraryController: CartDelegate {
  var basicBottomViewState: MediaToolbarState {
    return .Library
  }
  
  func cart(_ cart: Cart, didAdd video: Video) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
  }

  func cart(_ cart: Cart, didAdd audio: Audio) {
    //Nothing here
  }

  func cart(_ cart: Cart, didAdd image: Image) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
  }

  func cart(_ cart: Cart, didRemove image: Image) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
    configureFrameViews()
  }

  func cart(_ cart: Cart, didRemove audio: Audio) {
    //Nothing here
  }

  func cart(_ cart: Cart, didRemove video: Video) {
    pagesController.cartButton.updateCartItemsLabel(cart.items.count)
    configureFrameViews()
  }

  func cartDidReload(_ cart: Cart) {

  }
}

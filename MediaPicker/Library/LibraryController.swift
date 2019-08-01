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
  
  // MARK: - Init
  
  public required init() {
    super.init(nibName: nil, bundle: nil)
  }
  
  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setup()
  }
  
  // MARK: - Setup
  
  func setup() {
    view.backgroundColor = UIColor.white
    
    view.addSubview(gridView)
    
    addChild(dropdownController)
    gridView.insertSubview(dropdownController.view, belowSubview: gridView.topView)
    dropdownController.didMove(toParent: self)
    
    //gridView.bottomView.addSubview(stackView)
    
    gridView.g_pinEdges()
    
    dropdownController.view.g_pin(on: .left)
    dropdownController.view.g_pin(on: .right)
    dropdownController.view.g_pin(on: .height, constant: -40) // subtract gridView.topView height
    
    dropdownController.expandedTopConstraint = dropdownController.view.g_pin(on: .top, view: gridView.topView, on: .bottom, constant: 1)
    dropdownController.expandedTopConstraint?.isActive = false
    dropdownController.collapsedTopConstraint = dropdownController.view.g_pin(on: .top, on: .bottom)
    
//    stackView.g_pin(on: .centerY, constant: -4)
//    stackView.g_pin(on: .left, constant: 38)
//    stackView.g_pin(size: CGSize(width: 56, height: 56))
    
//    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
//    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
//    gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), for: .touchUpInside)
//    stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)
//
    
    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
  }
  
  // MARK: - Action
  
//  @objc func closeButtonTouched(_ button: UIButton) {
//    EventHub.shared.close?()
//  }
//
//  @objc func doneButtonTouched(_ button: UIButton) {
//    button.isEnabled = false
//    EventHub.shared.doneWithImages?()
//  }
  
  @objc func arrowButtonTouched(_ button: ArrowButton) {
    dropdownController.toggle()
    button.toggle(dropdownController.expanding)
  }
  
//  @objc func stackViewTouched(_ stackView: StackView) {
//    EventHub.shared.stackViewTouched?()
//  }
  
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
  
  // MARK: - View
  
  func refreshView() {
    let hasImages = false //!cart.images.isEmpty
    //gridView.bottomView.g_fade(visible: hasImages)
    gridView.collectionView.updateBottomInset(hasImages ? gridView.bottomView.frame.size.height : 0)
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
  
//  func makeStackView() -> StackView {
//    let view = StackView()
//
//    return view
//  }
}

extension LibraryController: PageAware {
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

//extension ImagesController: CartDelegate {
//  func cart(_ cart: Cart, didSet audio: Audio) {
//  }
//
//  func cart(_ cart: Cart, didSet video: Video) {
//  }
//
//  func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) {
//    stackView.reload(cart.images, added: true)
//    refreshView()
//
//    if newlyTaken {
//      refreshSelectedAlbum()
//    }
//  }
//
//  func cart(_ cart: Cart, didRemove image: Image) {
//    stackView.reload(cart.images)
//    refreshView()
//  }
//
//  func cartDidReload(_ cart: Cart) {
//    stackView.reload(cart.images)
//    refreshView()
//    refreshSelectedAlbum()
//  }
//}

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
//    let item = items[(indexPath as NSIndexPath).item]
//
//    if cart.images.contains(item) {
//      cart.remove(item)
//    } else {
//      if Config.Camera.imageLimit == 0 || Config.Camera.imageLimit > cart.images.count{
//        cart.add(item)
//      }
//    }
//
//    configureFrameViews()
  }
  
  func configureFrameViews() {
    for case let cell as ImageCell in gridView.collectionView.visibleCells {
      if let indexPath = gridView.collectionView.indexPath(for: cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }
  
  func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
//    let item = items[(indexPath as NSIndexPath).item]
//
//    if let index = cart.images.firstIndex(of: item) {
//      cell.frameView.g_quickFade()
//      cell.frameView.label.text = "\(index + 1)"
//    } else {
//      cell.frameView.alpha = 0
//    }
  }
}

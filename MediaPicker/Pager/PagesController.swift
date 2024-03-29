import UIKit

class PagesController: UIViewController, BottomViewCartDelegate {
  let controllers: [UIViewController]

  lazy var scrollView: UIScrollView = self.makeScrollView()
  lazy var scrollViewContentView: UIView = UIView()
  lazy var pageIndicator: PageIndicator = self.makePageIndicator()
  lazy var bottomView: BottomView = self.makeBottomView()
  lazy var topView: MediaPickerTopView = self.makeTopView()
  
  var cartView: CartCollectionView?
  
  var state: MediaToolbarState!
  var selectedIndex: Int!
  var cartOpened = false
  
  let once = Once()

  required init(controllers: [UIViewController]) {
    self.controllers = controllers

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupStartTab()

    view.backgroundColor = .white
    setup()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard scrollView.frame.size.width > 0 else {
      return
    }

    self.scrollTo(index: self.selectedIndex, animated: animated)
    self.notifyShow()
  }
  
  private func setupStartTab() {
    let startTab = Permission.startTab
    selectedIndex = startTab.rawValue
    switch Permission.startTab {
    case .libraryTab:
      state = .Library
    case .cameraTab:
      state = .Camera
    case .audioTab:
      state = .Audio
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

    coordinator.animate(alongsideTransition: { context in
      self.scrollTo(index: self.selectedIndex, animated: context.isAnimated)
    }) { _ in }

    super.viewWillTransition(to: size, with: coordinator)
  }

  // MARK: - Controls

  func makeScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.isScrollEnabled = false
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.alwaysBounceHorizontal = false
    scrollView.bounces = false
    scrollView.delegate = self

    return scrollView
  }

  func makePageIndicator() -> PageIndicator {
    let indicator = PageIndicator(frame: .zero)
    indicator.delegate = self
    indicator.translatesAutoresizingMaskIntoConstraints = false
    return indicator
  }

  func makeBottomView() -> BottomView {
    let bottomView = BottomView()
    bottomView.delegate = self
    bottomView.cartButton.delegate = self
    bottomView.translatesAutoresizingMaskIntoConstraints = false
    return bottomView
  }
  
  func makeTopView() -> MediaPickerTopView {
    let topView = MediaPickerTopView()
    topView.translatesAutoresizingMaskIntoConstraints = false
    return topView
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(pageIndicator)
    pageIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    pageIndicator.heightAnchor.constraint(equalToConstant: 70).isActive = true
    pageIndicator.widthAnchor.constraint(equalToConstant: MediaPickerConfig.shared.audio.includeAudioTab ? 270 : 180).isActive = true
    pageIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    
    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContentView)
    scrollView.g_pinUpward()
    scrollView.g_pin(on: .bottom, view: pageIndicator, on: .top)
    scrollViewContentView.g_pinEdges()

    for (i, controller) in controllers.enumerated() {
      addChild(controller)
      scrollViewContentView.addSubview(controller.view)
      controller.didMove(toParent: self)

      controller.view.g_pin(on: .top)
      controller.view.g_pin(on: .bottom)
      controller.view.g_pin(on: .width, view: scrollView)
      controller.view.g_pin(on: .height, view: scrollView)

      if i == 0 {
        controller.view.g_pin(on: .left)
      } else {
        controller.view.g_pin(on: .left, view: self.controllers[i - 1].view, on: .right)
      }

      if i == self.controllers.count - 1 {
        controller.view.g_pin(on: .right)
      }
    }

    view.addSubview(topView)
    topView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    topView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    topView.heightAnchor.constraint(equalToConstant: 40 + (UIApplication.shared.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top ?? 0) ).isActive = true
    topView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
    
    view.addSubview(bottomView)
    bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    bottomView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.shared.bottomView.height).isActive = true
    bottomView.bottomAnchor.constraint(equalTo: pageIndicator.topAnchor).isActive = true
    
    EventHub.shared.changeMediaPickerState = {
      stateFromEvent in
      self.updateViewStates(stateFromEvent)
      self.activeController?.switchedToState(state: stateFromEvent)
    }
  }
  
  var activeController: PageAware? {
    return self.controllers[self.selectedIndex] as? PageAware
  }

  // MARK: Index

  internal func scrollTo(index: Int, animated: Bool) {
    guard !scrollView.isTracking && !scrollView.isDragging && !scrollView.isZooming else {
      return
    }

    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
    scrollView.setContentOffset(point, animated: animated)
  }

  func updateAndNotify(_ index: Int) {
    guard selectedIndex != index else { return }

    notifyHide()
    selectedIndex = index
    notifyShow()
  }

  internal func updateViewStates(_ newState: MediaToolbarState) {
    state = newState
    bottomView.state = newState
    topView.state = newState
  }
  
  func notifyShow() {
    let activeTab = GalleryTab(rawValue: selectedIndex) ?? GalleryTab.libraryTab
    self.bottomView.activeTab = activeTab
    self.topView.activeTab = activeTab
    
    if controllers.count <= selectedIndex {
      selectedIndex = 0
    }
    if let controller = controllers[selectedIndex] as? PageAware {
      controller.pageDidShow()
      if cartOpened {
        hideCart()
      }
    }
  }

  func notifyHide() {
    if let controller = controllers[selectedIndex] as? PageAware {
      controller.pageDidHide()
    }
  }
  
  //Cart delegate
  func closeCartView() {
    self.hideCart()
  }
  
  func onItemDelete(guid: String) {
    onItemRemove(guid: guid)
  }
  
  func onItemTap(guid: String) {
    EventHub.shared.cartItemTappedAction?(guid)
  }
}







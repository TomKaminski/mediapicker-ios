import UIKit

protocol PageAware: AnyObject {
  func pageDidShow()
  func pageDidHide()
  
  var initialBottomViewState: MediaToolbarState { get }
}

class PagesController: UIViewController {

  let controllers: [UIViewController]

  lazy var scrollView: UIScrollView = self.makeScrollView()
  lazy var scrollViewContentView: UIView = UIView()
  lazy var pageIndicator: PageIndicator = self.makePageIndicator()
  lazy var cartButton: CartButton = self.makeCartButton()
  lazy var bottomView: BottomView = self.makeBottomView()
  
  var state = MediaToolbarState.Camera
  var selectedIndex: Int = 0
  var blockPageIndicator: Bool = false {
    didSet {
      scrollView.isScrollEnabled = false
    }
  }
  let once = Once()

  var pageIndicatorHeightConstraint: NSLayoutConstraint!

  // MARK: - Initialization

  required init(controllers: [UIViewController]) {
    self.controllers = controllers

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .black
    setup()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    guard scrollView.frame.size.width > 0 else {
      return
    }

    once.run {
      DispatchQueue.main.async {
        self.scrollToAndSelect(index: self.selectedIndex, animated: false)
      }

      notifyShow()
    }
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    let index = selectedIndex

    coordinator.animate(alongsideTransition: { context in
      self.scrollToAndSelect(index: index, animated: context.isAnimated)
    }) { _ in }

    super.viewWillTransition(to: size, with: coordinator)
  }

  // MARK: - Controls

  func makeScrollView() -> UIScrollView {
    let scrollView = UIScrollView()
    scrollView.isPagingEnabled = true
    scrollView.showsHorizontalScrollIndicator = false
    scrollView.alwaysBounceHorizontal = false
    scrollView.bounces = false
    scrollView.delegate = self

    return scrollView
  }
  
  func makeCartButton() -> CartButton {
    let button = CartButton()
    return button
  }

  func makePageIndicator() -> PageIndicator {
    let items = controllers.compactMap { $0.title }
    let indicator = PageIndicator(items: items)
    indicator.delegate = self

    return indicator
  }

  func makeBottomView() -> BottomView {
    return BottomView()
  }

  // MARK: - Setup

  func setup() {
    let usePageIndicator = controllers.count > 1
    pageIndicatorHeightConstraint = pageIndicator.heightAnchor.constraint(equalToConstant: 40)
    if usePageIndicator {
      view.addSubview(pageIndicator)
      Constraint.on(
        pageIndicator.leadingAnchor.constraint(equalTo: pageIndicator.superview!.leadingAnchor),
        pageIndicator.trailingAnchor.constraint(equalTo: pageIndicator.superview!.trailingAnchor),
        pageIndicatorHeightConstraint
      )

      if #available(iOS 11, *) {
        Constraint.on(
          pageIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        )
      } else {
        Constraint.on(
          pageIndicator.bottomAnchor.constraint(equalTo: pageIndicator.superview!.bottomAnchor)
        )
      }
    }

    view.addSubview(scrollView)
    scrollView.addSubview(scrollViewContentView)

    scrollView.g_pinUpward()
    if usePageIndicator {
      scrollView.g_pin(on: .bottom, view: pageIndicator, on: .top)
    } else {
      scrollView.g_pinDownward()
    }

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

    view.addSubview(bottomView)
    bottomView.delegate = self
    Constraint.on(
      bottomView.leadingAnchor.constraint(equalTo: bottomView.superview!.leadingAnchor),
      bottomView.trailingAnchor.constraint(equalTo: bottomView.superview!.trailingAnchor),
      bottomView.heightAnchor.constraint(equalToConstant: 100),
      bottomView.bottomAnchor.constraint(equalTo: pageIndicator.topAnchor)
    )
    
    view.addSubview(cartButton)
    cartButton.delegate = self
    Constraint.on(
      cartButton.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: -16),
      cartButton.trailingAnchor.constraint(equalTo: bottomView.superview!.trailingAnchor, constant: -16),
      cartButton.heightAnchor.constraint(equalToConstant: 40),
      cartButton.widthAnchor.constraint(equalToConstant: 40)
    )

    EventHub.shared.changeMediaPickerState = {
      stateFromEvent in
      self.changeBottomViewState(self.shuffleState())
      self.bottomView.setup()
      print("Changing state to.. \(self.state)")
    }
  }

  fileprivate func showPageIndicator() {
    pageIndicatorHeightConstraint.constant = 40
    pageIndicator.isHidden = false
    blockPageIndicator = false
  }
  
  fileprivate func hidePageIndicator() {
    pageIndicatorHeightConstraint.constant = 0
    pageIndicator.isHidden = true
    blockPageIndicator = true
  }
  
  
  private func shuffleState() -> MediaToolbarState {
    switch state {
    case .Camera:
      showPageIndicator()
      return .AudioRecording
    case .CartExpanded:
      hidePageIndicator()
      return .Camera
    case .VideoRecording:
      showPageIndicator()
      return .CartExpanded
    case .VideoTaken:
      hidePageIndicator()
      return .VideoRecording
    case .Library:
      showPageIndicator()
      return .VideoTaken
    case .Audio:
      showPageIndicator()
      return .Library
    case .AudioTaken:
      hidePageIndicator()
      return .Audio
    case .AudioRecording:
      showPageIndicator()
      return .AudioTaken
    }
  }

  // MARK: - Index

  fileprivate func scrollTo(index: Int, animated: Bool) {
    guard !scrollView.isTracking && !scrollView.isDragging && !scrollView.isZooming else {
      return
    }

    let point = CGPoint(x: scrollView.frame.size.width * CGFloat(index), y: scrollView.contentOffset.y)
    scrollView.setContentOffset(point, animated: animated)
  }

  fileprivate func scrollToAndSelect(index: Int, animated: Bool) {
    scrollTo(index: index, animated: animated)
    pageIndicator.select(index: index, animated: animated)
  }

  func updateAndNotify(_ index: Int) {
    guard selectedIndex != index else { return }

    notifyHide()
    selectedIndex = index
    notifyShow()
  }

  fileprivate func changeBottomViewState(_ newState: MediaToolbarState) {
    self.state = newState
    self.bottomView.state = self.state
    self.bottomView.setup()
  }
  
  func notifyShow() {
    if let controller = controllers[selectedIndex] as? PageAware {
      controller.pageDidShow()
      if bottomView.state != .CartExpanded {
        changeBottomViewState(controller.initialBottomViewState)
      }
    }
  }

  func notifyHide() {
    if let controller = controllers[selectedIndex] as? PageAware {
      controller.pageDidHide()
    }
  }
}

extension PagesController: PageIndicatorDelegate {

  fileprivate func executePageSelect(index: Int) {
    self.pageIndicator.select(index: index)
    self.scrollTo(index: index, animated: false)
    self.updateAndNotify(index)
  }

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    guard index != selectedIndex else {
      return
    }
    self.executePageSelect(index: index)
  }
}

extension PagesController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard !blockPageIndicator else {
      return
    }
    
    let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    pageIndicator.select(index: index)
    updateAndNotify(index)
  }
}

extension PagesController: BottomViewDelegate {
  var cartItems: [CartItemProtocol] {
    return self.mediaPickerController.cart.items
  }
  
  var mediaPickerController: MediaPickerController {
    return self.parent as! MediaPickerController
  }
  
  var itemsInCart: Int {
    return self.mediaPickerController.cart.items.count
  }
  
  func bottomView(_ changedStateTo: MediaToolbarState) {
    
  }
}

extension PagesController: CartButtonDelegate {
  func cartButtonTapped() {
    
    self.cartButton.cartOpened = !self.cartButton.cartOpened
    if self.cartButton.cartOpened {
      self.changeBottomViewState(.CartExpanded)
    } else {
      if let controller = controllers[selectedIndex] as? CartDelegate {
        self.changeBottomViewState(controller.basicBottomViewState);
      }
    }
    
    self.bottomView.setup()
  }
}

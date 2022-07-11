import UIKit

class PagesController: UIViewController {

  let controllers: [UIViewController]

  lazy var scrollView: UIScrollView = self.makeScrollView()
  lazy var scrollViewContentView: UIView = UIView()
  lazy var pageIndicator: PageIndicator = self.makePageIndicator()
  lazy var cartButton: StackView = self.makeStackView()
  lazy var bottomView: BottomView = self.makeBottomView()
  
  var state: MediaToolbarState!
  var selectedIndex: Int!
  
  let once = Once()

  var pageIndicatorHeightConstraint: NSLayoutConstraint!

  // MARK: Initialization

  required init(controllers: [UIViewController]) {
    self.controllers = controllers

    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupStartTab()

    view.backgroundColor = .black
    setup()
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

    coordinator.animate(alongsideTransition: { context in
      self.scrollToAndSelect(index: self.selectedIndex, animated: context.isAnimated)
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

  func makeStackView() -> StackView {
    let stackView = StackView()
    return stackView
  }

  func makePageIndicator() -> PageIndicator {
    let items = [
      MediaPickerConfig.instance.translationKeys.libraryTabTitleKey.g_localize(fallback: "LIBRARY"),
      MediaPickerConfig.instance.translationKeys.cameraTabTitleKey.g_localize(fallback: "CAMERA"),
      MediaPickerConfig.instance.translationKeys.audioTabTitleKey.g_localize(fallback: "AUDIO")
    ]
    
    let indicator = PageIndicator(items: items)
    indicator.delegate = self

    return indicator
  }

  func makeBottomView() -> BottomView {
    return BottomView()
  }

  // MARK: - Setup

  func setup() {
    pageIndicatorHeightConstraint = pageIndicator.heightAnchor.constraint(equalToConstant: 40)
    view.addSubview(pageIndicator)
    Constraint.on(
      pageIndicator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      pageIndicator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      pageIndicatorHeightConstraint
    )

    if #available(iOS 11, *) {
      Constraint.on(
        pageIndicator.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
      )
    } else {
      Constraint.on(
        pageIndicator.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      )
    }
    
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

    view.addSubview(bottomView)
    bottomView.delegate = self
    Constraint.on(
      bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      bottomView.heightAnchor.constraint(equalToConstant: MediaPickerConfig.instance.bottomView.height),
      bottomView.bottomAnchor.constraint(equalTo: pageIndicator.topAnchor)
    )
    
    view.addSubview(cartButton)
    cartButton.delegate = self
    Constraint.on(
      cartButton.bottomAnchor.constraint(equalTo: bottomView.topAnchor, constant: MediaPickerConfig.instance.bottomView.cartButton.bottomMargin),
      cartButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: MediaPickerConfig.instance.bottomView.cartButton.rightMargin),
      cartButton.heightAnchor.constraint(equalToConstant: 56),
      cartButton.widthAnchor.constraint(equalToConstant: 56)
    )
    
    EventHub.shared.changeMediaPickerState = {
      stateFromEvent in
      self.changeBottomViewState(stateFromEvent)
      self.bottomView.setup()
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

  internal func changeBottomViewState(_ newState: MediaToolbarState) {
    self.state = newState
    self.bottomView.state = self.state
    self.bottomView.setup()
  }
  
  func notifyShow() {
    self.bottomView.activeTab = MediaPickerConfig.instance.tabsToShow[selectedIndex]
    
    if controllers.count <= selectedIndex {
      selectedIndex = 0
    }
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







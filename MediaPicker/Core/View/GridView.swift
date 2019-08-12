import UIKit
import Photos

class GridView: UIView {
  
  // MARK: - Initialization
  
  lazy var topView: UIView = self.makeTopView()
  lazy var bottomView: UIView = self.makeBottomView()

  lazy var bottomBlurView: UIVisualEffectView = self.makeBottomBlurView()
  lazy var arrowButton: ArrowButton = self.makeArrowButton()
  lazy var collectionView: UICollectionView = self.makeCollectionView()
  lazy var shuffleStateTestButton: UIButton = self.makeShuffelStateButton()
  lazy var doneButton: UIButton = self.makeDoneButton()
  lazy var emptyView: UIView = self.makeEmptyView()
  lazy var loadingIndicator: UIActivityIndicatorView = self.makeLoadingIndicator()
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    loadingIndicator.startAnimating()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setup() {
    [collectionView, bottomView, topView, emptyView, loadingIndicator].forEach {
      addSubview($0)
    }
    
    [shuffleStateTestButton, arrowButton].forEach {
      topView.addSubview($0)
    }
    
    [bottomBlurView, doneButton].forEach {
      bottomView.addSubview($0)
    }
    
    Constraint.on(
      topView.leadingAnchor.constraint(equalTo: topView.superview!.leadingAnchor),
      topView.trailingAnchor.constraint(equalTo: topView.superview!.trailingAnchor),
      topView.heightAnchor.constraint(equalToConstant: 40),
      
      loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicator.superview!.centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: loadingIndicator.superview!.centerYAnchor)
    )
    
    if #available(iOS 11, *) {
      Constraint.on(
        topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
      )
    } else {
      Constraint.on(
        topView.topAnchor.constraint(equalTo: topView.superview!.topAnchor)
      )
    }
    
    bottomView.g_pinDownward()
    bottomView.g_pin(height: 80)
    
    emptyView.g_pinEdges(view: collectionView)
    
    collectionView.g_pinDownward(view: bottomView)
    collectionView.g_pin(on: .top, view: topView, on: .bottom, constant: 1)
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    
    bottomBlurView.g_pinEdges()
    
    shuffleStateTestButton.g_pin(on: .top)
    shuffleStateTestButton.g_pin(on: .left)
    shuffleStateTestButton.g_pin(size: CGSize(width: 40, height: 40))
    
    arrowButton.g_pinCenter()
    arrowButton.g_pin(height: 40)
    
    doneButton.g_pin(on: .centerY)
    doneButton.g_pin(on: .right, constant: -38)
  }
  
  // MARK: - Controls
  
  private func makeTopView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.white
    
    return view
  }
  
  private func makeBottomView() -> UIView {
    let view = UIView()
    
    return view
  }
  
  private func makeBottomBlurView() -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    return view
  }
  
  private func makeArrowButton() -> ArrowButton {
    let button = ArrowButton()
    button.layoutSubviews()
    
    return button
  }
  
  private func makeGridView() -> GridView {
    let view = GridView()
    
    return view
  }
  
  private func makeShuffelStateButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(MediaPickerBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControl.State())
    button.tintColor = Config.Grid.CloseButton.tintColor
    
    return button
  }
  
  private func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("LandaxApp_Gallery_Done".g_localize(fallback: "Done"), for: UIControl.State())
    
    return button
  }
  
  private func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.white
    
    return view
  }
  
  private func makeEmptyView() -> EmptyView {
    let view = EmptyView()
    view.isHidden = true
    
    return view
  }
  
  private func makeLoadingIndicator() -> UIActivityIndicatorView {
    let view = UIActivityIndicatorView(style: .whiteLarge)
    view.color = .gray
    view.hidesWhenStopped = true
    
    return view
  }
}

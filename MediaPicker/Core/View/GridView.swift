import UIKit
import Photos

class GridView: UIView {
  lazy var topView: UIView = self.makeTopView()
  lazy var bottomView: UIView = self.makeBottomView()

  lazy var bottomBlurView: UIVisualEffectView = self.makeBottomBlurView()
  lazy var arrowButton: ArrowButton = self.makeArrowButton()
  lazy var collectionView: UICollectionView = self.makeCollectionView()
  lazy var doneButton: UIButton = self.makeDoneButton()
  lazy var emptyView: UIView = self.makeEmptyView()
  lazy var loadingIndicator: UIActivityIndicatorView = self.makeLoadingIndicator()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setup()
    loadingIndicator.startAnimating()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    [collectionView, bottomView, topView, emptyView, loadingIndicator].forEach {
      addSubview($0)
    }
    
    [arrowButton].forEach {
      topView.addSubview($0)
    }
    
    [bottomBlurView, doneButton].forEach {
      bottomView.addSubview($0)
    }
    
    Constraint.on(
      topView.leadingAnchor.constraint(equalTo: topView.superview!.leadingAnchor),
      topView.trailingAnchor.constraint(equalTo: topView.superview!.trailingAnchor),
      topView.heightAnchor.constraint(equalToConstant: 40),
      topView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),

      loadingIndicator.centerXAnchor.constraint(equalTo: loadingIndicator.superview!.centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: loadingIndicator.superview!.centerYAnchor)
    )
    
    bottomView.g_pinDownward()
    bottomView.g_pin(height: 80)
    
    emptyView.g_pinEdges(view: collectionView)
    
    collectionView.g_pinDownward(view: bottomView)
    collectionView.g_pin(on: .top, view: topView, on: .bottom, constant: 1)
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
    
    bottomBlurView.g_pinEdges()
    
    arrowButton.g_pinCenter()
    arrowButton.g_pin(height: 40)
    
    doneButton.g_pin(on: .centerY)
    doneButton.g_pin(on: .right, constant: -38)
  }
  
  private func makeTopView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.black
    
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
    
  private func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
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
    let view = UIActivityIndicatorView(style: .large)
    view.color = .gray
    view.hidesWhenStopped = true
    
    return view
  }
}

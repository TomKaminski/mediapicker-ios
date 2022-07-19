import UIKit
import Photos

class GridView: UIView {
  lazy var collectionView: UICollectionView = self.makeCollectionView()
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
    [collectionView, loadingIndicator].forEach {
      addSubview($0)
    }

    loadingIndicator.g_pinCenter()
    collectionView.g_pin(on: .top, constant: 40 + (UIApplication.shared.windows.first(where: \.isKeyWindow)?.safeAreaInsets.top ?? 0))
    collectionView.g_pin(on: .leading)
    collectionView.g_pin(on: .trailing)
    collectionView.g_pin(on: .bottom)
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
  }

  private func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2
    
    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.white
    
    return view
  }
  
  private func makeLoadingIndicator() -> UIActivityIndicatorView {
    let view = UIActivityIndicatorView(style: .large)
    view.color = .gray
    view.hidesWhenStopped = true
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }
}

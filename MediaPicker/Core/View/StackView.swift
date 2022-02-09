import UIKit
import Photos

protocol CartButtonDelegate: AnyObject {
  func cartButtonTapped()
}

class StackView: UIControl {
  weak var delegate: CartButtonDelegate?

  lazy var indicator: UIActivityIndicatorView = self.makeIndicator()
  lazy var imageViews: [UIImageView] = self.makeImageViews()
  lazy var countLabel: UILabel = self.makeCountLabel()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()
  
  var cartOpened: Bool = false {
    didSet {
//      toggleVisibility()
    }
  }

  // MARK: - Initialization
  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup
  func setup() {
    addGestureRecognizer(tapGR)
    imageViews.forEach {
      addSubview($0)
    }

    [countLabel, indicator].forEach {
      self.addSubview($0)
    }
  }

  // MARK: - Layout
  override func layoutSubviews() {
    super.layoutSubviews()

    let step: CGFloat = 3.0
    let scale: CGFloat = 0.8
    let imageViewSize = CGSize(width: frame.width * scale,
                          height: frame.height * scale)

    for (index, imageView) in imageViews.enumerated() {
      let origin = CGPoint(x: CGFloat(index) * step,
                           y: CGFloat(imageViews.count - index) * step)
      imageView.frame = CGRect(origin: origin, size: imageViewSize)
    }
  }

  // MARK: - Action
  @objc func viewTapped(_ gr: UITapGestureRecognizer) {
    delegate?.cartButtonTapped()
  }

  // MARK: - Logic
  func startLoading() {
    if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last {
      indicator.center = topVisibleView.center
    } else if let first = imageViews.first {
      indicator.center = first.center
    }

    indicator.startAnimating()
    UIView.animate(withDuration: 0.3, animations: {
      self.indicator.alpha = 1.0
    })
  }

  func stopLoading() {
    indicator.stopAnimating()
    indicator.alpha = 0
  }

  func renderViews(_ assets: [CartItemProtocol]) {
    let photos = Array(assets.suffix(MediaPickerConfig.instance.stackView.imageCount))

    for (index, view) in imageViews.enumerated() {
      if index < photos.count {
        view.loadImageThumbnail(photos[index])
        view.alpha = 1
      } else {
        view.image = nil
        view.alpha = 0
      }
    }
  }

  fileprivate func animate(imageView: UIImageView) {
    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
        imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      }

      UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
        imageView.transform = CGAffineTransform.identity
      }

    }, completion: { finished in
      
    })
  }

  // MARK: - Reload
  func reload(_ items: [CartItemProtocol], added: Bool = false) {
//    // Animate empty view
    if added {
      if let emptyView = imageViews.filter({ $0.image == nil }).first {
        animate(imageView: emptyView)
      }
    }

    // Update images into views
    renderViews(items)

    // Update count label
    if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last , items.count > 1 {
      countLabel.text = "\(items.count)"
      countLabel.sizeToFit()
      countLabel.center = topVisibleView.center
      countLabel.quickFade()
    } else {
      countLabel.alpha = 0
    }
  }
  
  // MARK: - Controls
  func makeIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView()
    indicator.alpha = 0

    return indicator
  }

  func makeImageViews() -> [UIImageView] {
    return Array(0..<MediaPickerConfig.instance.stackView.imageCount).map { _ in
      let imageView = UIImageView()

      imageView.contentMode = .scaleAspectFill
      imageView.alpha = 0
      imageView.addRoundBorder()

      return imageView
    }
  }

  func makeCountLabel() -> UILabel {
    let label = UILabel()
    label.textColor = MediaPickerConfig.instance.cartButton.textColor
    label.font = MediaPickerConfig.instance.cartButton.font
    label.textAlignment = .center
    label.addShadow()
    label.alpha = 0

    return label
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))

    return gr
  }
}

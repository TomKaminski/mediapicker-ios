public class EditorView: UIView {
  lazy var topToolbarView: TopToolbarView = TopToolbarView()
  lazy var centerView: UIView = UIView()
  lazy var bottomToolbarView: UIView = UIView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    
    backgroundColor = UIColor.black
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    [topToolbarView, centerView, bottomToolbarView].forEach { self.addSubview($0) }
    
    centerView.backgroundColor = .purple
    bottomToolbarView.backgroundColor = .green
  }
  
  public override func updateConstraints() {
    topToolbarView.translatesAutoresizingMaskIntoConstraints = false
    centerView.translatesAutoresizingMaskIntoConstraints = false
    bottomToolbarView.translatesAutoresizingMaskIntoConstraints = false

    NSLayoutConstraint.activate([
      self.topToolbarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.topToolbarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.topToolbarView.topAnchor.constraint(equalTo: self.topAnchor),
      self.topToolbarView.heightAnchor.constraint(equalToConstant: 60),

      self.centerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.centerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.centerView.topAnchor.constraint(equalTo: self.topToolbarView.bottomAnchor),
      self.centerView.bottomAnchor.constraint(equalTo: self.bottomToolbarView.topAnchor),

      self.bottomToolbarView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      self.bottomToolbarView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      self.bottomToolbarView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      self.bottomToolbarView.heightAnchor.constraint(equalToConstant: 100)
    ])

    
    super.updateConstraints()
  }
}

class CartCollectionScrollView: GenericHorizontalScrollView<CartCollectionItemView> {
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addItems([CartCollectionItemView(), CartCollectionItemView(), CartCollectionItemView(), CartCollectionItemView(), CartCollectionItemView(), CartCollectionItemView(), CartCollectionItemView(), CartCollectionItemView()])
  }
  
  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

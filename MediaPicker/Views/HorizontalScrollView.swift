import UIKit

struct MarginSettings {
  public var mainMargin: CGFloat = 10
  public var marginBetweenItems: CGFloat = 7.0
  
  public init(mainMargin: CGFloat = 10, marginBetweenItems: CGFloat = 7.0) {
    self.mainMargin = mainMargin
    self.marginBetweenItems = marginBetweenItems
  }
}

class GenericHorizontalScrollView<TView: UIView>: UIScrollView {
  override open var frame: CGRect{
    didSet{
      if(frame.width != oldValue.width){
        self.refreshSubView()
      }
    }
  }
  
  public var itemY: CGFloat = 10
  public var items: [TView] = []
  public var shouldCenterSubViews: Bool = false
  
  open var singleItemHeight: CGFloat = 60
  
  public var defaultMarginSettings = MarginSettings()
    public var mainMargin: CGFloat {
    get {
      return self.defaultMarginSettings.mainMargin
    }
  }
  
  public var marginBetweenItems: CGFloat {
    get {
      return self.defaultMarginSettings.marginBetweenItems
    }
  }
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    initView()
  }
  
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initView()
  }
  
  public func scrollToEnd() {
    let rightOffset = CGPoint(x: self.contentSize.width - self.bounds.size.width, y: 0)
    self.setContentOffset(rightOffset, animated: false)
  }
  
  fileprivate func initView() {
    self.showsHorizontalScrollIndicator = false
    self.backgroundColor = .white
    self.decelerationRate = UIScrollView.DecelerationRate.fast
  }
  
  override open func touchesShouldCancel(in view: UIView) -> Bool {
    if view.isKind(of: UIButton.self) {
      return true
    }
    return false
  }
  
  open func addItem(_ item: TView) {
    if self.items.count > 0 {
      let lastItem = self.items[self.items.count-1]
      let lastItemRect = lastItem.frame
      
      item.frame = CGRect(x: lastItemRect.origin.x + lastItem.frame.width + self.marginBetweenItems, y: itemY, width: self.singleItemHeight, height: self.singleItemHeight)
    }
    else {
      item.frame = CGRect(x: self.mainMargin, y: itemY, width: self.singleItemHeight, height: self.singleItemHeight)
    }
    
    items.append(item)
    self.addSubview(item)
    
    self.contentSize = CGSize(width: item.frame.origin.x + self.singleItemHeight + self.mainMargin, height: self.frame.size.height)
  }
  
  open func addItems(_ items:[TView]) {
    for item in items {
      self.addItem(item)
    }
  }
  
  open func removeItem(_ item: TView) -> Bool {
    guard let index = self.items.firstIndex(of: item) else {
      return false
    }
    
    return self.removeItemAtIndex(index)
  }
  
  open func removeAllItems() -> Bool {
    if self.items.count == 0 {
      return false
    }
    
    for i in (0...self.items.count-1).reversed() {
      let item:UIView = self.items[i]
      item.removeFromSuperview()
    }
    self.items.removeAll(keepingCapacity: false)
    self.contentSize = self.frame.size
    
    return true
  }
  
  open func removeItemAtIndex(_ index:Int) -> Bool {
    if (index < 0 || index > self.items.count-1) { return false }
    //set new x position from index to the end
    
    let itemToRemove:UIView = self.items[index]
    let removedItemWidth = itemToRemove.frame.width
    
    if index != self.items.count-1{
      for i in (index+1...self.items.count-1).reversed() {
        let item:UIView = self.items[i]
        item.frame = CGRect(x: item.frame.minX-self.marginBetweenItems-removedItemWidth, y: item.frame.minY, width: item.frame.width, height: item.frame.height)
      }
    }
    
    itemToRemove.removeFromSuperview()
    self.items.remove(at: index)
    self.contentSize = CGSize(width: self.contentSize.width-self.marginBetweenItems-removedItemWidth, height: self.frame.size.height)
    
    return true
  }
  
  public func refreshSubView() {
    var itemX = self.mainMargin
    if self.shouldCenterSubViews {
      itemX = centerSubviews()
    }
    else {
      itemX = self.reorderSubViews()
    }
    self.contentSize = CGSize(width: itemX, height: self.frame.size.height)
  }
  
  private func reorderSubViews() -> CGFloat {
    var itemX = self.mainMargin
    for item in self.items {
      item.frame = CGRect(x: itemX, y: item.frame.origin.y, width: item.frame.width, height: item.frame.height)
      itemX += item.frame.width + self.marginBetweenItems
    }
    
    return itemX - self.marginBetweenItems + self.mainMargin
  }
  
  
  public func centerSubviews() -> CGFloat {
    if let itemLastX = self.items.last?.frame.maxX {
      if itemLastX + self.mainMargin < self.frame.size.width {
        
        let allItemsWidth = self.items.reduce(0.0) { (width, view) -> CGFloat in
          var result = width
          result += view.frame.width
          return result
        }
        
        let marginsWidth = self.marginBetweenItems * CGFloat(self.items.count)
        
        let extraGap = (self.frame.size.width - (marginsWidth + allItemsWidth) + self.marginBetweenItems - self.mainMargin * 2) / 2
        var itemX = self.mainMargin + extraGap
        for item in self.items
        {
          item.frame = CGRect(x: itemX, y: item.frame.origin.y, width: item.frame.width, height: item.frame.height)
          itemX += item.frame.width + self.mainMargin
        }
        return itemX - self.marginBetweenItems + self.mainMargin + extraGap;
      }
      return self.reorderSubViews()
    }
    return 0
  }
}

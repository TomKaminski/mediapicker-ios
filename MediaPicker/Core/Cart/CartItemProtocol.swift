public protocol CartItemProtocol {
  var guid: String { get set }
  
  var cartView: CartCollectionItemView { get }
  var type: CartItemType { get }
}

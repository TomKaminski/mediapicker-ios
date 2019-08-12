public enum CartItemType {
  case Audio
  case Video
  case Image
}

public protocol CartItemProtocol {
  var guid: String { get set }
  
  var cartView: CartCollectionItemView { get }
  var type: CartItemType { get }
  
  func removeSelfFromCart()
  func runPreviewOrEdit()
}

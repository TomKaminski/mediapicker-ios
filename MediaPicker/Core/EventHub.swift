import Foundation

class EventHub {
  
  typealias Action = () -> Void
  
  static let shared = EventHub()
  
  // MARK: Initialization
  
  init() {}
  
  var close: Action?
  var doneWithMedia: Action?
  var changeMediaPickerState: ((MediaToolbarState) -> Void)?
}

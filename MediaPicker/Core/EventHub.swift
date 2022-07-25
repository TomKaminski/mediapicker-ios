import Foundation

class EventHub {
  typealias Action = () -> Void
  typealias GuidAction = ((String) -> Void)
  
  static let shared = EventHub()
  
  init() {}
  
  var close: Action?
  var doneWithMediaPicker: Action?
  var changeMediaPickerState: ((MediaToolbarState) -> Void)?
  var selfDeleteFromCart: GuidAction?
  var executeCustomAction: GuidAction?
}

import UIKit

class FlashButton: UIButton {
  let states: [UIImage]
  var selectedIndex: Int = 0
    
  init(states: [UIImage]) {
    self.states = states
    super.init(frame: .zero)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setup() {    
    select(index: selectedIndex)
  }
  
  @discardableResult func toggle() -> Int {
    selectedIndex = (selectedIndex + 1) % states.count
    select(index: selectedIndex)
    
    return selectedIndex
  }
  
  func select(index: Int) {
    guard index < states.count else { return }
    setImage(states[index], for: UIControl.State())
  }
}

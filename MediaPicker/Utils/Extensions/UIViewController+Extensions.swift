import UIKit

extension UIViewController {
  func addChildController(_ controller: UIViewController) {
    addChild(controller)
    view.addSubview(controller.view)
    controller.didMove(toParent: self)

    controller.view.g_pin(on: .topMargin)
    controller.view.g_pin(on: .bottom)
    controller.view.g_pin(on: .left)
    controller.view.g_pin(on: .right)
  }
  
  func removeFromParentController() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}

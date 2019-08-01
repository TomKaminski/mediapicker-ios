import UIKit
import MediaPicker

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func onAddTap(_ sender: Any) {
    let picker = MediaPickerController()
    self.navigationController?.pushViewController(picker, animated: true)
  }
}


//
//  ViewController.swift
//  MediaPickerExample
//
//  Created by Tomasz Kaminski on 7/25/19.
//  Copyright © 2019 Tomasz Kaminski. All rights reserved.
//

import UIKit
import MediaPicker

class ViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func onTapAdd(_ sender: Any) {
    let picker = MediaPickerController()
    self.present(picker, animated: true, completion: nil)
  }
}


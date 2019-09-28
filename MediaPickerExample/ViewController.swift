//
//  ViewController.swift
//  MediaPickerExample
//
//  Created by Tomasz Kaminski on 7/25/19.
//  Copyright © 2019 Tomasz Kaminski. All rights reserved.
//

import UIKit
import MediaPicker

class ViewController: UIViewController, MediaPickerControllerDelegate {
  func mediaPicker(_ controller: MediaPickerController, didSelectMedia media: [CartItemProtocol]) {
    
    controller.dismiss(animated: true) {
      let images = media.compactMap { $0 as? Image }
      let audios = media.compactMap { $0 as? Audio }
      let videos = media.compactMap { $0 as? Video }

      let alert = UIAlertController(title: "Media picker finished", message: "Selected images: \(images.count), selected video: \(videos.count), selected audio: \(audios.count)", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
        alert.dismiss(animated: true, completion: nil)
      }))
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  func mediaPickerDidCancel(_ controller: MediaPickerController) {
    //none
  }
  

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  @IBAction func onTapAdd(_ sender: Any) {
    let picker = MediaPickerController()
    picker.modalPresentationStyle = .overFullScreen
    picker.delegate = self
    self.present(picker, animated: true, completion: nil)
  }
}


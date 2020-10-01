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
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
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
    controller.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onLeftAddTap(_ sender: Any) {
    let picker = MediaPickerController()
    picker.modalPresentationStyle = .overFullScreen
    picker.delegate = self
    
    MediaPickerConfig.instance = MediaPickerConfig()
    MediaPickerConfig.instance.camera.allowPhotoEdit = true
    MediaPickerConfig.instance.tabsToShow = [.libraryTab, .cameraTab]
    MediaPickerConfig.instance.camera.recordMode = .photo
    MediaPickerConfig.instance.bottomView.cart.maxItems = 1
    MediaPickerConfig.instance.videoRecording.allow = false
    

    self.present(picker, animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setNeedsStatusBarAppearanceUpdate()
    // Do any additional setup after loading the view.
  }

  @IBAction func onTapAdd(_ sender: Any) {
    let picker = MediaPickerController()
    picker.modalPresentationStyle = .overFullScreen
    picker.delegate = self
    
    MediaPickerConfig.instance = MediaPickerConfig()
    MediaPickerConfig.instance.camera.allowPhotoEdit = true

    self.present(picker, animated: true, completion: nil)
  }
}


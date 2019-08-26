//
//  PhotoEditor+Controls.swift
//  Pods
//
//  Created by Mohamed Hamed on 6/16/17.
//
//

import Foundation
import UIKit

// MARK: - Control
public enum control {
  case crop
  case draw
  case text
  case clear
}

extension PhotoEditorViewController {

  //MARK: Top Toolbar

  @IBAction func cancelButtonTapped(_ sender: Any) {
    photoEditorDelegate?.canceledEditing()
    self.dismiss(animated: true, completion: nil)
  }

  @IBAction func drawButtonTapped(_ sender: Any) {
    isDrawing = true
    canvasImageView.isUserInteractionEnabled = false
    doneButton.isHidden = false
    continueButton.isHidden = true
    colorPickerView.isHidden = false
    hideToolbar(hide: true)
  }

  @IBAction func textButtonTapped(_ sender: Any) {
    isTyping = true
    doneButton.isHidden = false
    continueButton.isHidden = true
    colorPickerView.isHidden = false
    hideToolbar(hide: true)

    let textView = UITextView(frame: CGRect(x: 0, y: canvasImageView.center.y,
                                            width: UIScreen.main.bounds.width, height: 30))

    textView.textAlignment = .center
    textView.font = UIFont(name: "Helvetica", size: 30)
    textView.textColor = textColor
    textView.layer.shadowColor = UIColor.black.cgColor
    textView.layer.shadowOffset = CGSize(width: 1.0, height: 0.0)
    textView.layer.shadowOpacity = 0.2
    textView.layer.shadowRadius = 1.0
    textView.layer.backgroundColor = UIColor.clear.cgColor
    textView.autocorrectionType = .no
    textView.isScrollEnabled = false
    textView.delegate = self
    textView.returnKeyType = .done
    self.canvasImageView.addSubview(textView)
    addGestures(view: textView)
    textView.becomeFirstResponder()
  }

  @IBAction func doneButtonTapped(_ sender: Any) {
    view.endEditing(true)
    doneButton.isHidden = true
    continueButton.isHidden = false
    colorPickerView.isHidden = true
    canvasImageView.isUserInteractionEnabled = true
    hideToolbar(hide: false)
    isDrawing = false
    isTyping = false
    
    clearButton.isHidden = !isImageEdited()
  }

  //MARK: Bottom Toolbar
  @IBAction func clearButtonTapped(_ sender: AnyObject) {
    //clear drawing
    canvasImageView.image = nil
    //clear stickers and textviews
    for subview in canvasImageView.subviews {
      subview.removeFromSuperview()
    }
    
    clearButton.isHidden = true
  }
  
  private func isImageEdited() -> Bool {
    return canvasImageView.image != nil || !canvasImageView.subviews.isEmpty
  }

  @IBAction func continueButtonPressed(_ sender: Any) {
    let img = self.canvasView.toImage()
    photoEditorDelegate?.doneEditing(image: img, selfCtrl: self, editedSomething: isImageEdited())
  }

  //MARK: helper methods
  func hideControls() {
    for control in hiddenControls {
      switch control {
      case .clear:
        clearButton.isHidden = true
      case .draw:
        drawButton.isHidden = true
      default:
        break
      }
    }
  }


  func addGestures(view: UIView) {
    //Gestures
    view.isUserInteractionEnabled = true

    let panGesture = UIPanGestureRecognizer(target: self,
                                            action: #selector(PhotoEditorViewController.panGesture))
    panGesture.minimumNumberOfTouches = 1
    panGesture.maximumNumberOfTouches = 1
    panGesture.delegate = self
    view.addGestureRecognizer(panGesture)

    let pinchGesture = UIPinchGestureRecognizer(target: self,
                                                action: #selector(PhotoEditorViewController.pinchGesture))
    pinchGesture.delegate = self
    view.addGestureRecognizer(pinchGesture)

    let rotationGestureRecognizer = UIRotationGestureRecognizer(target: self,
                                                                action: #selector(PhotoEditorViewController.rotationGesture))
    rotationGestureRecognizer.delegate = self
    view.addGestureRecognizer(rotationGestureRecognizer)

    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(PhotoEditorViewController.tapGesture))
    view.addGestureRecognizer(tapGesture)

  }

}

//
//  Protocols.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 6/15/17.
//
//

import Foundation
import UIKit
/**
 - didSelectView
 - didSelectImage
 */

public protocol PhotoEditorDelegate {
  /**
   - Parameter image: edited Image
   */
  func doneEditing(image: UIImage, selfCtrl: PhotoEditorController)
  func canceledEditing()
}

/**
 - didSelectColor
 */
protocol ColorDelegate {
  func didSelectColor(color: UIColor)
}

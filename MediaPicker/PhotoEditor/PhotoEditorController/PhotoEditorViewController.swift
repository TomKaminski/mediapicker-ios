//
//  ViewController.swift
//  Photo Editor
//
//  Created by Mohamed Hamed on 4/23/17.
//  Copyright © 2017 Mohamed Hamed. All rights reserved.
//

import UIKit

public final class PhotoEditorViewController: UIViewController {
  
  /** holding the 2 imageViews original image and drawing & stickers */
  @IBOutlet weak var canvasView: UIView!
  //To hold the image
  @IBOutlet var imageView: UIImageView!
  @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
  //To hold the drawings and stickers
  @IBOutlet weak var canvasImageView: UIImageView!

  @IBOutlet weak var bottomToolbarConstraint: NSLayoutConstraint!
  @IBOutlet weak var topToolbar: UIView!
  @IBOutlet weak var bottomToolbar: UIView!

  @IBOutlet weak var topGradient: UIView!
  @IBOutlet weak var bottomGradient: UIView!

  @IBOutlet weak var continueButton: UIButton!
  @IBOutlet weak var doneButton: UIButton!
  @IBOutlet weak var deleteView: UIView!
  @IBOutlet weak var colorsCollectionView: UICollectionView!
  @IBOutlet weak var colorPickerView: UIView!
  @IBOutlet weak var colorPickerViewBottomConstraint: NSLayoutConstraint!

  //Controls
  @IBOutlet weak var drawButton: UIButton!
  @IBOutlet weak var textButton: UIButton!
  @IBOutlet weak var clearButton: UIButton!

  public var image: UIImage?
  /**
     Array of Stickers -UIImage- that the user will choose from
     */
  public var stickers: [UIImage] = []
  /**
     Array of Colors that will show while drawing or typing
     */
  public var colors: [UIColor] = []

  public var photoEditorDelegate: PhotoEditorDelegate?
  var colorsCollectionViewDelegate: ColorsCollectionViewDelegate!

  // list of controls to be hidden
  public var hiddenControls: [control] = [.crop]

  var stickersVCIsVisible = false
  var drawColor: UIColor = UIColor.red
  var textColor: UIColor = UIColor.white
  var isDrawing: Bool = false
  var lastPoint: CGPoint!
  var swiped = false
  var lastPanPoint: CGPoint?
  var lastTextViewTransform: CGAffineTransform?
  var lastTextViewTransCenter: CGPoint?
  var lastTextViewFont: UIFont?
  var activeTextView: UITextView?
  var imageViewToPan: UIImageView?
  var isTyping: Bool = false

  //Register Custom font before we load XIB
  public override func loadView() {
    super.loadView()
  }

  override public func viewDidLoad() {
    super.viewDidLoad()
    self.setImageView(image: image!)

    deleteView.clipsToBounds = true
    clearButton.layer.cornerRadius = 15
    clearButton.isHidden = true

    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)),
                                           name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    configureCollectionView()
    hideControls()
    
    //Show drawing at start
    canvasImageView.isUserInteractionEnabled = false
    continueButton.isHidden = false
    doneButton.isHidden = true
    colorPickerView.isHidden = true
    hideToolbar(hide: false)
  }

  func configureCollectionView() {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: 30, height: 30)
    layout.scrollDirection = .horizontal
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    colorsCollectionView.collectionViewLayout = layout
    colorsCollectionViewDelegate = ColorsCollectionViewDelegate()
    colorsCollectionViewDelegate.colorDelegate = self
    if !colors.isEmpty {
      colorsCollectionViewDelegate.colors = colors
    }
    colorsCollectionView.delegate = colorsCollectionViewDelegate
    colorsCollectionView.dataSource = colorsCollectionViewDelegate

    colorsCollectionView.register(UINib(nibName: "ColorCollectionViewCell", bundle: Bundle(for: ColorCollectionViewCell.self)),
                                  forCellWithReuseIdentifier: "ColorCollectionViewCell")
  }

  func setImageView(image: UIImage) {
    imageView.image = image
    let size = image.suitableSize(widthLimit: UIScreen.main.bounds.width)
    imageViewHeightConstraint.constant = (size?.height)!
  }

  func hideToolbar(hide: Bool) {
    topToolbar.isHidden = hide
  }
}

extension PhotoEditorViewController: ColorDelegate {
  func didSelectColor(color: UIColor) {
    if isDrawing {
      self.drawColor = color
    } else if activeTextView != nil {
      activeTextView?.textColor = color
      textColor = color
    }
  }
}






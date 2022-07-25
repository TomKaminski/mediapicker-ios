protocol CircularButtonConformance {
  func makeCircularButton(with imageName: String) -> CircularBorderButton
}

extension CircularButtonConformance {
  func makeCircularButton(with imageName: String) -> CircularBorderButton {
    let btn = CircularBorderButton(frame: .zero)
    
    btn.setImage(MediaPickerBundle.image(imageName), for: .normal)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.widthAnchor.constraint(equalToConstant: MediaPickerConfig.shared.photoEditor.editorCircularButtonSize).isActive = true
    btn.heightAnchor.constraint(equalToConstant: MediaPickerConfig.shared.photoEditor.editorCircularButtonSize).isActive = true
    
    return btn
  }
  
}

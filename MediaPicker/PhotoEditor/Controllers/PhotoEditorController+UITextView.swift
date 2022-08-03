extension PhotoEditorController: UITextViewDelegate {
  public func textViewDidChange(_ textView: UITextView) {
    let rotation = atan2(textView.transform.b, textView.transform.a)
    if rotation == 0 {
      let oldFrame = textView.frame
      let sizeToFit = textView.sizeThatFits(CGSize(width: oldFrame.width, height: CGFloat.greatestFiniteMagnitude))
      textView.frame.size = CGSize(width: oldFrame.width, height: sizeToFit.height)
    }
  }
  
  public func textViewDidBeginEditing(_ textView: UITextView) {
    isTyping = true
    activeTextView = textView
    textView.superview?.bringSubviewToFront(textView)
    textView.font = UIFont.systemFont(ofSize: 24)
  }
  
  public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      doneButtonTapped()
      editedSomething = true
      return true
    }
    return true
  }
  
  public func textViewDidEndEditing(_ textView: UITextView) {
    activeTextView = nil
  }
  
  private func doneButtonTapped() {
    view.endEditing(true)
    canvasImageView.isUserInteractionEnabled = true
    isTyping = false
  }
  
  @objc func onKeyboardHide() {
    view.endEditing(true)
    canvasImageView.isUserInteractionEnabled = true
    isTyping = false
  }
}

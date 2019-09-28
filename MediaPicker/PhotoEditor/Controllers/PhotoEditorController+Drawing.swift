extension PhotoEditorController {
  override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !isTyping {
      swiped = false
      if let touch = touches.first {
        lastPoint = touch.location(in: self.canvasImageView)
      }
    }
  }
  
  override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !isTyping {
      swiped = true
      if let touch = touches.first {
        let currentPoint = touch.location(in: canvasImageView)
        drawLineFrom(lastPoint, toPoint: currentPoint)
        lastPoint = currentPoint
      }
    }
  }
  
  override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if !isTyping {
      if !swiped {
        drawLineFrom(lastPoint, toPoint: lastPoint)
      }
    }
  }
  
  private func drawLineFrom(_ fromPoint: CGPoint, toPoint: CGPoint) {
    let canvasSize = canvasImageView.frame.integral.size
    UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
    if let context = UIGraphicsGetCurrentContext() {
      canvasImageView.image?.draw(in: CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height))
      context.move(to: CGPoint(x: fromPoint.x, y: fromPoint.y))
      context.addLine(to: CGPoint(x: toPoint.x, y: toPoint.y))
      context.setLineCap( CGLineCap.round)
      context.setLineWidth(Config.PhotoEditor.lineWidth)
      context.setStrokeColor(drawColor.cgColor)
      context.setBlendMode(CGBlendMode.normal)
      context.strokePath()
      canvasImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    }
    UIGraphicsEndImageContext()
  }
}

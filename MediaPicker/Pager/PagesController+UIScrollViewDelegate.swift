extension PagesController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let index = Int(round(scrollView.contentOffset.x / scrollView.frame.size.width))
    pageIndicator.select(index: index)
    updateAndNotify(index)
  }
}

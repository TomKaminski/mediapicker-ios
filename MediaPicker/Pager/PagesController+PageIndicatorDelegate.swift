extension PagesController: PageIndicatorDelegate {
  fileprivate func executePageSelect(index: Int) {
    pageIndicator.select(index: index)
    scrollTo(index: index, animated: false)
    updateAndNotify(index)
  }

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    guard index != selectedIndex else {
      return
    }
    
    executePageSelect(index: index)
  }
}

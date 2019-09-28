extension PagesController: PageIndicatorDelegate {
  fileprivate func executePageSelect(index: Int) {
    self.pageIndicator.select(index: index)
    self.scrollTo(index: index, animated: false)
    self.updateAndNotify(index)
  }

  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    guard index != selectedIndex else {
      return
    }
    self.executePageSelect(index: index)
  }
}

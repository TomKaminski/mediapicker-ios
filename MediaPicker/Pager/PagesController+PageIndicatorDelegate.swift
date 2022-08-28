extension PagesController: PageIndicatorDelegate {
  func pageIndicator(_ pageIndicator: PageIndicator, didSelect index: Int) {
    guard index != selectedIndex else {
      return
    }
    
    scrollTo(index: index, animated: false)
  }
}

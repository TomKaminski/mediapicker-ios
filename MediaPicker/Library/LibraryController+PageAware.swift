extension LibraryController: PageAware {
  func switchedToState(state: MediaToolbarState) {
    
  }
  
  var initialBottomViewState: MediaToolbarState {
    return .Library
  }

  func pageDidHide() {

  }

  func pageDidShow() {
    once.run {
      library.reload {
        self.gridView.loadingIndicator.stopAnimating()
        self.dropdownController.albums = self.library.albums
        self.dropdownController.tableView.reloadData()

        if let album = self.library.albums.first {
          self.selectedAlbum = album
          self.show(album: album)
        }
      }
    }
  }
}

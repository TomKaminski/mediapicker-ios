extension LibraryController: DropdownControllerDelegate {
  func dropdownController(_ controller: DropdownController, didSelect album: Album) {
    selectedAlbum = album
    show(album: album)

    dropdownController.toggle()
    gridView.arrowButton.toggle(controller.expanding)
  }
}

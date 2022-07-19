extension LibraryController: DropdownControllerDelegate {
  func dropdownController(_ controller: DropdownController, didSelect album: Album) {
    selectedAlbum = album
    show(album: album)

    dropdownController.toggle()
    pagesController.topView.dropdownButton.toggle(controller.expanding)
  }
}

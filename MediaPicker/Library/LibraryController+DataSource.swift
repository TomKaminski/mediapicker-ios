extension LibraryController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count + videos.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell: UICollectionViewCell
    if indexPath.row < images.count {
      cell = configureImageCell(collectionView, cellForItemAt: indexPath)
    } else {
      cell = configureVideoCell(collectionView, cellForItemAt: indexPath)
    }

    return cell
  }

  private func configureImageCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
    as! ImageCell
    let nsIndexPath = (indexPath as NSIndexPath)
    let item = images[nsIndexPath.item]

    cell.configure(item)
    configureFrameView(cell, indexPath: indexPath)
    return cell
  }

  private func configureVideoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath)
    as! VideoCell
    let nsIndexPath = (indexPath as NSIndexPath)
    let item = videos[nsIndexPath.item - self.images.count]

    cell.configure(item)
    configureFrameView(cell, indexPath: indexPath)
    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    var size = (collectionView.bounds.size.width - (MediaPickerConfig.instance.grid.dimension.columnCount - 1) * MediaPickerConfig.instance.grid.dimension.cellSpacing)
    / MediaPickerConfig.instance.grid.dimension.columnCount
    
    if size > 200 {
      size = 200
    }
    return CGSize(width: size, height: size)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    pagesController.cartButton.startLoading()

    var newItem = getCartItem(indexPath: indexPath)
    newItem.dateAdded = Date()
    if let itemFromCart = cart.getItem(by: newItem.guid) {
      cart.remove(itemFromCart)
    } else {
      cart.add(newItem)
    }

    configureFrameViews()
  }

  private func getCartItem(indexPath: IndexPath) -> CartItemProtocol {
    if indexPath.row < images.count {
      return images[indexPath.row]
    } else {
      return videos[indexPath.row - self.images.count]
    }
  }

  func configureFrameViews() {
    for case let cell as ImageCell in gridView.collectionView.visibleCells {
      if let indexPath = gridView.collectionView.indexPath(for: cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }

  func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
    let newItem = getCartItem(indexPath: indexPath)
    if cart.getItem(by: newItem.guid) != nil {
      cell.frameView.quickFade()
    } else {
      cell.frameView.alpha = 0
    }
  }

  var pagesController: PagesController {
    return self.parent as! PagesController
  }
}


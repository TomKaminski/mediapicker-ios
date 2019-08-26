import UIKit

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  var colorDelegate: ColorDelegate?
  
  /**
   Array of Colors that will show while drawing or typing
   */
  var colors = [
    UIColor.black,
    UIColor.white,
    UIColor.blue,
    UIColor.green,
    UIColor.red,
    UIColor.yellow
  ]
  
  override init() {
    super.init()
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return colors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    colorDelegate?.didSelectColor(color: colors[indexPath.item])
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
    cell.colorView.backgroundColor = colors[indexPath.item]
    return cell
  }
  
}

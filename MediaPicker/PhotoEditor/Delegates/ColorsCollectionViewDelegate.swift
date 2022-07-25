import UIKit

class ColorsCollectionViewDelegate: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  var colorDelegate: ColorSelectedDelegate?

  var colors: [UIColor] = [
    .white,
    .black,
    .blue,
    .cyan,
    .green,
    .red,
    .yellow,
    .orange,
    .brown,
    .purple,
    .magenta,
    .gray,
  ]
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return colors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    colorDelegate?.didSelectColor(color: colors[indexPath.item])
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return .init(width: 30, height: 40)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColorCollectionViewCell", for: indexPath) as! ColorCollectionViewCell
    let color = colors[indexPath.item]
    cell.colorView.backgroundColor = color
    cell.isSelected = color == UIColor.red
    return cell
  }
}

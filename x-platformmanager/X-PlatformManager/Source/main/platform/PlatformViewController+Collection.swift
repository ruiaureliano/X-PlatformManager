import Cocoa

extension PlatformViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {

	func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
		return platforms.count
	}

	func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
		let cell = self.storyboard?.instantiateController(withIdentifier: .platformCellView) as! PlatformCellView
		let platform = platforms[indexPath.item]
		cell.setPlatform(platform: platform, xcode: xcode)
		return cell
	}

	func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
		return NSSize(width: 130, height: 120)
	}
}

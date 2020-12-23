import Cocoa

extension MainSplitViewController: XcodeViewControllerDelegate {
	func xcodeSelectionDidChange(index: Int, xcode: Xcode) {
		self.xcode = xcode
		platformViewController?.reloadPlatformsData(xcode: xcode)
		updateTitle()
	}
}

extension MainSplitViewController: PlatformViewControllerDelegate {
}

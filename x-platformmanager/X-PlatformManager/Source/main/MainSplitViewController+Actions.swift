import Cocoa

extension MainSplitViewController {

	@IBAction func appleTvPress(_ item: NSToolbarItem) {

		self.platformViewController?.platformType = .appleTVOS
		self.platformType = .appleTVOS
		updateTitle()
	}

	@IBAction func watchPress(_ item: NSToolbarItem) {
		self.platformViewController?.platformType = .watchOS
		self.platformType = .watchOS
		updateTitle()
	}

	@IBAction func iphonePress(_ item: NSToolbarItem) {
		self.platformViewController?.platformType = .iPhoneOS
		self.platformType = .iPhoneOS
		updateTitle()
	}

	@IBAction func leftButton(_ button: NSButton) {
		var splitViewOpen = true
		if self.splitView.subviews.count > 1 {
			let split = self.splitView.subviews[1]
			splitViewOpen = split.frame.origin.x > 0
		}
		if splitViewOpen {
			splitWidth = splitViewItems.first?.viewController.view.frame.size.width ?? kDefaultSplitWidth
			splitView.setPosition(0, ofDividerAt: 0)
		} else {
			splitView.setPosition(splitWidth, ofDividerAt: 0)
		}
	}
}

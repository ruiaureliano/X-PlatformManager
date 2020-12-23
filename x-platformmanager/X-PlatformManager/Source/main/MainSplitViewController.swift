import Cocoa

let kDefaultSplitWidth: CGFloat = 220

class MainSplitViewController: NSSplitViewController {

	var splitWidth: CGFloat = kDefaultSplitWidth
	var platformType: PlatformType = .iPhoneOS

	var xcode: Xcode?
	var xcodeViewController: XcodeViewController?
	var platformViewController: PlatformViewController?

	override func viewDidLoad() {
		super.viewDidLoad()

		for item in self.splitViewItems {
			if let xcodeViewController = item.viewController as? XcodeViewController {
				xcodeViewController.delegate = self
				self.xcodeViewController = xcodeViewController
			} else if let platformViewController = item.viewController as? PlatformViewController {
				platformViewController.delegate = self
				self.platformViewController = platformViewController
			}
		}
		xcode = DataSource.shared.xcodes.first
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		guard let toolbar = self.view.window?.toolbar else { return }
		toolbar.selectedItemIdentifier = NSToolbarItem.Identifier(rawValue: platformType.rawValue)
		updateTitle()
	}

	func updateTitle() {
		if let xcode = xcode {
			self.view.window?.title = "\(xcode) ➤ \(platformType.rawValue)"
		}
	}
}

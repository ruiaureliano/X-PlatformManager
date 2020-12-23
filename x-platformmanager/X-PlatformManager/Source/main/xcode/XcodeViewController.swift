import Cocoa

protocol XcodeViewControllerDelegate: class {
	func xcodeSelectionDidChange(index: Int, xcode: Xcode)
}

class XcodeViewController: NSViewController {

	@IBOutlet weak var xcodeTableView: NSTableView!

	var xcodes: [Xcode] = DataSource.shared.xcodes
	weak var delegate: XcodeViewControllerDelegate?

	override func viewDidLoad() {
		super.viewDidLoad()

		Notifications.shared.observe(name: .xcodeDidChanged) { _ in
			self.xcodes = DataSource.shared.xcodes
			self.reloadXcodeData()
		}
		reloadXcodeData()
	}

	func reloadXcodeData() {
		DispatchQueue.main.async {
			self.xcodeTableView.reloadData()
			if self.xcodes.count > 0 {
				self.xcodeTableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
			}
		}
	}
}

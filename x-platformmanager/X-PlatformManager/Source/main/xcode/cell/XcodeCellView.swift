import Cocoa

extension NSUserInterfaceItemIdentifier {
	static let xcodeCellView = NSUserInterfaceItemIdentifier(rawValue: "XcodeCellView")
}

class XcodeCellView: NSView {

	@IBOutlet weak var iconView: NSImageView!
	@IBOutlet weak var titleView: NSTextField!
	@IBOutlet weak var subtitleView: NSTextField!

	func setInstance(instance: Xcode) {
		iconView.image = instance.icon
		titleView.stringValue = instance.name
		subtitleView.stringValue = "Version \(instance.version) (\(instance.build))"
	}
}

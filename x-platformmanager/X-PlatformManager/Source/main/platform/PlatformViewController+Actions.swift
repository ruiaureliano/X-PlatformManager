import Cocoa

extension PlatformViewController {

	@IBAction func appVersionButtonPopover(_ button: NSButton) {
		let width = 240
		let controller = NSViewController()
		let popover = NSPopover()
		self.popover = popover
		controller.view = NSView(frame: NSRect(x: 0, y: 0, width: width, height: 70))
		popover.contentViewController = controller
		popover.contentSize = controller.view.frame.size
		popover.behavior = .semitransient
		popover.animates = true

		let textField = NSTextField(string: "🚀 \(appUpdateVersionName ?? "Version: 1.0")")
		textField.frame = NSRect(x: 10, y: 32, width: width - 20, height: 20)
		textField.isBezeled = false
		textField.drawsBackground = true
		textField.backgroundColor = .clear
		textField.isEditable = false
		textField.isSelectable = false
		textField.alignment = .center
		controller.view.addSubview(textField)

		let downloadVersion = NSButton(frame: NSRect(x: (width - 100) / 2, y: 5, width: 100, height: 32))
		downloadVersion.isBordered = false
		downloadVersion.title = "Download"
		downloadVersion.image = NSImage(named: "default-download-bt")
		downloadVersion.target = self
		downloadVersion.action = #selector(self.appUpdateVersionButtonPress(_:))
		downloadVersion.bezelStyle = .rounded
		controller.view.addSubview(downloadVersion)

		popover.show(relativeTo: .zero, of: button, preferredEdge: .maxY)
	}

	@objc private func appUpdateVersionButtonPress(_ button: NSButton) {
		popover?.close()
		if let appUpdateVersionButtonURL = appUpdateVersionButtonURL {
			if let url = URL(string: appUpdateVersionButtonURL) {
				NSWorkspace.shared.open(url)
			}
		}
	}
}

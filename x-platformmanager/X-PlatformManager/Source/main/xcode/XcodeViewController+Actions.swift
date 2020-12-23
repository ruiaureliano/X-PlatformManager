import Cocoa

extension XcodeViewController {

	@IBAction func addXcodeButton(_ button: NSButton) {
		let openPanel = NSOpenPanel()
		openPanel.showsHiddenFiles = true
		openPanel.canChooseDirectories = false
		openPanel.allowsMultipleSelection = false
		openPanel.allowedFileTypes = ["app"]
		openPanel.directoryURL = URL(fileURLWithPath: "/Applications/")

		if let window = NSApp.mainWindow {
			openPanel.beginSheetModal(for: window) { response in
				if response.rawValue == 1 {
					if let path = openPanel.urls.first?.path {
						DataSource.shared.addXcode(path: path)
					}
				}
			}
		} else {
			let response = openPanel.runModal()
			if response.rawValue == 1 {
				if let path = openPanel.urls.first?.path {
					DataSource.shared.addXcode(path: path)
				}
			}
		}
	}

	@IBAction func removeXcodeButton(_ button: NSButton) {
		if xcodeTableView.selectedRow >= 0 {
			let xcode = self.xcodes[self.xcodeTableView.selectedRow]
			let alert = NSAlert()
			alert.alertStyle = .informational
			alert.messageText = "Delete \(xcode)"
			alert.informativeText = "Are you sure?"
			alert.addButton(withTitle: "OK")
			alert.addButton(withTitle: "Cancel")

			if let window = NSApp.mainWindow {
				alert.beginSheetModal(for: window) { response in
					if response.rawValue == 1000 {
						DataSource.shared.removeXcode(xcode: xcode)
					}
				}
			} else {
				let response = alert.runModal()
				if response.rawValue == 1000 {
					DataSource.shared.removeXcode(xcode: xcode)
				}
			}
		}
	}
}

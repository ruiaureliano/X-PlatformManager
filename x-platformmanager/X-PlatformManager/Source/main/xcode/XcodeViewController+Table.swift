import Cocoa

extension XcodeViewController: NSTableViewDataSource, NSTableViewDelegate {

	func numberOfRows(in tableView: NSTableView) -> Int {
		return xcodes.count
	}

	func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return 40
	}

	func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		if let cell = tableView.makeView(withIdentifier: .xcodeCellView, owner: self) as? XcodeCellView {
			cell.setInstance(instance: xcodes[row])
			return cell
		}
		return nil
	}

	func tableViewSelectionDidChange(_ notification: Notification) {
		if xcodeTableView.selectedRow >= 0 {
			let xcode = self.xcodes[self.xcodeTableView.selectedRow]
			delegate?.xcodeSelectionDidChange(index: xcodeTableView.selectedRow, xcode: xcode)
		}
	}
}

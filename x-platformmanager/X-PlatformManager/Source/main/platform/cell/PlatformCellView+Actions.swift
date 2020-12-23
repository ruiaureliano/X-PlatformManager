import Cocoa

extension PlatformCellView {

	@IBAction func actionButtonPress(_ button: NSButton) {
		guard let instance = self.platform else { return }
		let menu = NSMenu(title: "")
		switch type {
		case .cloud:
			let downloadItem = NSMenuItem(title: "Download & Install \(instance.name)", action: #selector(self.downloadItemPress(_:)), keyEquivalent: "")
			downloadItem.image = NSImage(systemSymbolName: "icloud.and.arrow.down", accessibilityDescription: nil)
			downloadItem.target = self
			downloadItem.tag = 1
			menu.addItem(downloadItem)
		case .local:
			let installItem = NSMenuItem(title: "Install \(instance.name)", action: #selector(self.installItemPress(_:)), keyEquivalent: "")
			installItem.image = NSImage(systemSymbolName: "square.grid.3x1.folder.badge.plus", accessibilityDescription: nil)
			installItem.target = self
			installItem.tag = 2
			menu.addItem(installItem)
		case .installed:
			let deleteItem = NSMenuItem(title: "Delete \(instance.name)", action: #selector(self.deleteItemPress(_:)), keyEquivalent: "")
			deleteItem.image = NSImage(systemSymbolName: "trash", accessibilityDescription: nil)
			deleteItem.target = self
			deleteItem.tag = 3
			menu.addItem(deleteItem)
		}
		menu.popUp(positioning: nil, at: NSPoint(x: 0, y: 30), in: button)
	}

	@objc func downloadItemPress(_ menuItem: NSMenuItem) {
		guard
			let platform = self.platform,
			let xcode = self.xcode,
			let signatureURL = platform.signatureURL,
			let dmgURL = platform.dmgURL
		else {
			return
		}

		let alert = NSAlert()
		alert.alertStyle = .informational
		alert.messageText = "Download & Install \(platform.name) for \(xcode)"
		alert.informativeText = "Are you sure?"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")

		if let window = NSApp.mainWindow {
			alert.beginSheetModal(for: window) { response in
				if response.rawValue == 1000 {
					self.downloadPlatform(signatureURL: signatureURL, dmgURL: dmgURL)
				}
			}
		} else {
			let response = alert.runModal()
			if response.rawValue == 1000 {
				self.downloadPlatform(signatureURL: signatureURL, dmgURL: dmgURL)
			}
		}
	}

	@objc func installItemPress(_ menuItem: NSMenuItem) {
		guard
			let platform = self.platform,
			let xcode = self.xcode,
			let srcPath = platform.path
		else {
			return
		}

		let dstPath = "\(xcode.path)/Contents/Developer/Platforms/\(platform.type.rawValue).platform/DeviceSupport"
		let alert = NSAlert()
		alert.alertStyle = .informational
		alert.messageText = "Install \(platform.name) for \(xcode)"
		alert.informativeText = "Are you sure?"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")

		if let window = NSApp.mainWindow {
			alert.beginSheetModal(for: window) { response in
				if response.rawValue == 1000 {
					self.copy(srcPath: srcPath, dstPath: dstPath, platform: platform)
				}
			}
		} else {
			let response = alert.runModal()
			if response.rawValue == 1000 {
				self.copy(srcPath: srcPath, dstPath: dstPath, platform: platform)
			}
		}
	}

	@objc func deleteItemPress(_ menuItem: NSMenuItem) {
		guard
			let platform = self.platform,
			let xcode = self.xcode
		else {
			return
		}
		var path = "\(xcode.path)/Contents/Developer/Platforms/\(platform.type.rawValue).platform/DeviceSupport/\(platform.version)"
		if platform.build.count > 0 {
			path.append(" (\(platform.build))")
		}
		let alert = NSAlert()
		alert.alertStyle = .informational
		alert.messageText = "Delete \(platform.name) for \(xcode)"
		alert.informativeText = "Are you sure?"
		alert.addButton(withTitle: "OK")
		alert.addButton(withTitle: "Cancel")

		if let window = NSApp.mainWindow {
			alert.beginSheetModal(for: window) { response in
				if response.rawValue == 1000 {
					self.deletePlatform(path: path, platform: platform)
				}
			}
		} else {
			let response = alert.runModal()
			if response.rawValue == 1000 {
				self.deletePlatform(path: path, platform: platform)
			}
		}
	}

	private func deletePlatform(path: String, platform: Platform) {

		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
			let shellScript =
				"""
												set srcPath to "\(path)/"
												set srcPathQuoted to quoted form of POSIX path of srcPath
												do shell script "/bin/rm -R " & srcPathQuoted with administrator privileges
												"""
			if let script = NSAppleScript(source: shellScript) {
				var error: NSDictionary?
				script.executeAndReturnError(&error)
				if error == nil {
					DataSource.shared.reloadPlatforms()
					Sound.glass()
				} else {
					self.errorAlert(message: "Platform \(platform.name) not deleted")
				}
			} else {
				self.errorAlert(message: "Platform \(platform.name) not deleted")
			}
		}
	}

	private func downloadPlatform(signatureURL: String, dmgURL: String) {

		DispatchQueue.main.async {
			self.actionButton.isEnabled = false
			self.progressView.progress = 0
			self.progressView.isHidden = false
		}

		Downloader.shared.download(url: signatureURL) { _ in
		} success: { signatureData in
			Downloader.shared.download(url: dmgURL) { progress in
				DispatchQueue.main.async {
					self.progressView.progress = Int(progress * 100)
				}
			} success: { dmgData in
				DispatchQueue.main.async {
					self.actionButton.isEnabled = true
					self.progressView.progress = 100
					self.progressView.isHidden = true
				}

				guard
					let platform = self.platform,
					let xcode = self.xcode
				else {
					return
				}

				let path = "\(xcode.path)/Contents/Developer/Platforms/\(platform.type.rawValue).platform/DeviceSupport"
				self.installPlatform(signatureData: signatureData, dmgData: dmgData, path: path, platform: platform)

			} failure: { error in
				self.errorAlert(message: error.localizedDescription)
			}

		} failure: { error in
			self.errorAlert(message: error.localizedDescription)
		}
	}

	private func installPlatform(signatureData: Data, dmgData: Data, path: String, platform: Platform) {
		var shellScript = ""
		var createFolder: Bool = false
		let url = URL(fileURLWithPath: "\(path)/\(self.version)")
		if !FileManager.default.directoryExists(atPath: url.path) {
			createFolder = true
			shellScript.append("set crtPath to \"\(path)/\(self.version)\"\n")
			shellScript.append("set crtPathQuoted to quoted form of POSIX path of crtPath\n")
		}
		if createFolder {
			shellScript.append("do shell script \"/bin/mkdir \" & crtPathQuoted with administrator privileges\n")
		}

		let signaturePath = "\(NSTemporaryDirectory())DeveloperDiskImage.dmg.signature"
		let dmgPath = "\(NSTemporaryDirectory())DeveloperDiskImage.dmg"
		let signatureSave = FileManager.default.createFile(atPath: signaturePath, contents: signatureData, attributes: nil)
		let dmgSave = FileManager.default.createFile(atPath: dmgPath, contents: dmgData, attributes: nil)

		if signatureSave && dmgSave {
			shellScript.append("set signatureSrcPath to \"\(signaturePath)\"\n")
			shellScript.append("set dmgSrcPath to \"\(dmgPath)\"\n")
			shellScript.append("set signatureDstPath to \"\(path)/\(self.version)/DeveloperDiskImage.dmg.signature\"\n")
			shellScript.append("set dmgDstPath to \"\(path)/\(self.version)/DeveloperDiskImage.dmg\"\n")
			shellScript.append("set signatureSrcPathQuoted to quoted form of POSIX path of signatureSrcPath\n")
			shellScript.append("set dmgSrcPathQuoted to quoted form of POSIX path of dmgSrcPath\n")
			shellScript.append("set signatureDstPathQuoted to quoted form of POSIX path of signatureDstPath\n")
			shellScript.append("set dmgDstPathQuoted to quoted form of POSIX path of dmgDstPath\n")
			shellScript.append("do shell script ")
			shellScript.append("\"/bin/mv \" & signatureSrcPathQuoted & \" \" & signatureDstPathQuoted &")
			shellScript.append("\";/bin/mv \" & dmgSrcPathQuoted & \" \" & dmgDstPathQuoted ")
			shellScript.append("with administrator privileges\n")
		}

		if let script = NSAppleScript(source: shellScript) {
			var error: NSDictionary?
			script.executeAndReturnError(&error)
			if error == nil {
				DataSource.shared.reloadPlatforms()
				Sound.glass()
			} else {
				self.errorAlert(message: "Platform \(platform.name) not installed")
			}
		} else {
			self.errorAlert(message: "Platform \(platform.name) not installed")
		}
	}

	private func copy(srcPath: String, dstPath: String, platform: Platform) {
		DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
			let shellScript =
				"""
												set srcPath to "\(srcPath)/\(self.version)"
												set dstPath to "\(dstPath)"
												set srcPathQuoted to quoted form of POSIX path of srcPath
												set dstPathQuoted to quoted form of POSIX path of dstPath
												do shell script "/bin/cp -R " & srcPathQuoted & " " & dstPathQuoted with administrator privileges
												"""

			if let script = NSAppleScript(source: shellScript) {
				var error: NSDictionary?
				script.executeAndReturnError(&error)
				if error == nil {
					DataSource.shared.reloadPlatforms()
					Sound.glass()
				} else {
					self.errorAlert(message: "Platform \(platform.name) not installed")
				}
			} else {
				self.errorAlert(message: "Platform \(platform.name) not installed")
			}
		}
	}

	private func errorAlert(message: String) {
		DispatchQueue.main.async {
			let alert = NSAlert()
			alert.alertStyle = .critical
			alert.messageText = "Error!"
			alert.informativeText = message
			alert.addButton(withTitle: "OK")
			Sound.basso()
			if let window = NSApp.mainWindow {
				alert.beginSheetModal(for: window) { _ in
				}
			} else {
				_ = alert.runModal()
			}
		}
	}
}

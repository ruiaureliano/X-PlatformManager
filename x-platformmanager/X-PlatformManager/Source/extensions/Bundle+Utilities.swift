import Cocoa

extension Bundle {

	var CFBundleShortVersionString: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}

	var CFBundleVersion: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}

	var CFBundleIdentifier: String? {
		return infoDictionary?["CFBundleIdentifier"] as? String
	}

	var CFBundleExecutable: String? {
		return infoDictionary?["CFBundleExecutable"] as? String
	}

	var CFBundleIcon: NSImage? {
		if let iconFile = infoDictionary?["CFBundleIconFile"] as? String {
			return NSImage(named: iconFile)
		}
		return nil
	}
}

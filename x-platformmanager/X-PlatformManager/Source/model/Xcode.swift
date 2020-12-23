import Cocoa

class Xcode: NSObject, Codable {

	var name: String = ""
	var version: String = ""
	var build: String = ""
	var path: String = ""
	var bundle: String = ""

	convenience init(name: String, version: String, build: String, path: String, bundle: String) {
		self.init()

		self.name = name
		self.version = version
		self.build = build
		self.path = path
		self.bundle = bundle
	}

	override var description: String {
		return "\(name) \(version) (\(build))"
	}

	override var debugDescription: String {
		return "\(name) \(version) (\(build))"
	}

	var icon: NSImage? {
		return NSWorkspace.shared.icon(forFile: path)
	}

	override func isEqual(_ object: Any?) -> Bool {
		guard let instance = object as? Xcode else { return false }
		return version == instance.version && build == instance.build && path == instance.path
	}
}

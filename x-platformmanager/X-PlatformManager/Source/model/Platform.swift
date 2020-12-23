import Foundation

enum PlatformType: String {
	case appleTVOS = "AppleTVOS"
	case iPhoneOS = "iPhoneOS"
	case watchOS = "WatchOS"
}

enum PlatformStatus: String {
	case cloud
	case local
}

class Platform: NSObject, Codable {

	private var _type: String = PlatformType.iPhoneOS.rawValue
	private var _status: String = PlatformStatus.local.rawValue
	var name: String = "iPhoneOS (1.0)"
	var version: String = "1.0"
	var build: String = ""
	private var _xcodes: [Xcode] = []
	var path: String?
	var dmgURL: String?
	var signatureURL: String?

	convenience init(type: PlatformType, status: PlatformStatus, version: String, build: String, xcode: Xcode? = nil, path: String? = nil, dmgURL: String? = nil, signatureURL: String? = nil) {
		self.init()
		self._type = type.rawValue
		self._status = status.rawValue
		self.name = "\(type.rawValue) (\(version))"
		self.version = version
		self.build = build
		if let xcode = xcode {
			self._xcodes = [xcode]
		}

		self.path = path
		self.dmgURL = dmgURL
		self.signatureURL = signatureURL
	}

	override var description: String {
		return "\(name) \(build) [status: \(status)]"
	}

	override func isEqual(_ object: Any?) -> Bool {
		guard let instance = object as? Platform else {
			return false
		}
		return name == instance.name
	}

	var type: PlatformType {
		guard let platformType = PlatformType(rawValue: _type) else {
			return .iPhoneOS
		}
		return platformType
	}

	var status: PlatformStatus {
		guard let platformStatus = PlatformStatus(rawValue: _status) else {
			return .local
		}
		return platformStatus
	}

	var xcodes: [Xcode] {
		return _xcodes
	}

	func installXcode(xcode: Xcode) -> Bool {
		if !_xcodes.contains(xcode) {
			_xcodes.append(xcode)
			return true
		}
		return false
	}
}

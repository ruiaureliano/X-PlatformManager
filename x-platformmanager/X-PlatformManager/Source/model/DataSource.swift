import Foundation

private let kUserDefaultsXcodeIntances = "UserDefaultsXcodeIntances"
private let kXcodeBundleIdentifier = "com.apple.dt.Xcode"
private let kPlatformsCloudURL: String = "https://raw.githubusercontent.com/ruiaureliano/X-PlatformManager/main/platforms/platforms.json"

class DataSource: NSObject {

	static let shared = DataSource()

	private var _xcodes: [Xcode] = []
	private var _cloudPlatforms: [Platform] = []
	private var _localPlatforms: [Platform] = []

	private var _platforms: [Platform] {
		var platforms: [Platform] = []
		for platform in _localPlatforms {
			platforms.append(platform)
		}
		for platform in _cloudPlatforms {
			if !platforms.contains(platform) {
				platforms.append(platform)
			}
		}
		return platforms
	}

	var xcodes: [Xcode] {
		return _xcodes.sorted { xc1, xc2 in
			return xc1.version.compare(xc2.version, options: .numeric) == .orderedDescending
		}
	}

	override init() {
		super.init()
		if let data = UserDefaults.standard.object(forKey: kUserDefaultsXcodeIntances) as? Data, let xcodes = try? JSONDecoder().decode([Xcode].self, from: data) {
			_xcodes = xcodes
		}
	}

	func validate() {
		validateXcodes()
		checkXcodeApplicationsFolder()
		saveXcodes(notify: true)
		checkLocalPlatforms(index: 0) { _ in
			self.loadCloud { platforms, _ in
				self._cloudPlatforms = platforms
				self.savePlatforms(notify: true)
			}
		}
	}

	func reloadPlatforms() {
		_localPlatforms = []
		checkLocalPlatforms(index: 0) { _ in
			self.loadCloud { platforms, _ in
				self._cloudPlatforms = platforms
				self.savePlatforms(notify: true)
			}
		}
	}

	func platforms(for type: PlatformType) -> [Platform] {
		if _xcodes.count == 0 {
			return []
		}
		return _platforms.filter { platform in
			return platform.type == type
		}.sorted { p1, p2 in
			return p1.version.compare(p2.version, options: .numeric) == .orderedDescending
		}
	}
}

extension DataSource { /* XCODES */

	private func saveXcodes(notify: Bool) {
		if let data = try? JSONEncoder().encode(_xcodes) {
			UserDefaults.standard.setValue(data, forKey: kUserDefaultsXcodeIntances)
			UserDefaults.standard.synchronize()
		}

		if notify {
			Notifications.shared.postNotification(name: .xcodeDidChanged, object: nil)
		}
	}

	private func validateXcodes() {
		for xcode in _xcodes {
			if evalualeXcodeInstance(path: xcode.path) == nil {
				_xcodes.remove(object: xcode)
			}
		}
	}

	private func evalualeXcodeInstance(path: String) -> Xcode? {
		let plist = "\(path)/Contents/Info.plist"
		let url = URL(fileURLWithPath: plist)
		guard
			let data = try? Data(contentsOf: url),
			let dictionary = try? PropertyListSerialization.propertyList(from: data, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
		else {
			return nil
		}

		guard
			let CFBundleIdentifier = dictionary["CFBundleIdentifier"] as? String,
			let CFBundleExecutable = dictionary["CFBundleExecutable"] as? String,
			CFBundleIdentifier == kXcodeBundleIdentifier
		else {
			return nil
		}

		let version = "\(path)/Contents/version.plist"
		let xcodeURL = URL(fileURLWithPath: version)

		guard
			let xcodeData = try? Data(contentsOf: xcodeURL),
			let xcodeDictionary = try? PropertyListSerialization.propertyList(from: xcodeData, options: .mutableContainersAndLeaves, format: nil) as? [String: Any]
		else {
			return nil
		}

		guard
			let CFBundleShortVersionString = xcodeDictionary["CFBundleShortVersionString"] as? String,
			let ProductBuildVersion = xcodeDictionary["ProductBuildVersion"] as? String
		else {
			return nil
		}

		return Xcode(name: CFBundleExecutable, version: CFBundleShortVersionString, build: ProductBuildVersion, path: path, bundle: CFBundleIdentifier)
	}

	private func checkXcodeApplicationsFolder() {
		if let apps = try? FileManager.default.contentsOfDirectory(atPath: "/Applications/") {
			for app in apps {
				if let xcode = evalualeXcodeInstance(path: "/Applications/\(app)") {
					if !_xcodes.contains(xcode) {
						_xcodes.append(xcode)
					} else {
						replace(xcode: xcode)
					}
				}
			}
		}
	}

	private func replace(xcode: Xcode) {
		guard let index = (_xcodes.firstIndex { _xcode in return _xcode == xcode }), index < _xcodes.count else { return }
		_xcodes[index] = xcode
	}

	func addXcode(path: String) {
		if let xcode = self.evalualeXcodeInstance(path: path) {
			if !_xcodes.contains(xcode) {
				_xcodes.append(xcode)
			} else {
				replace(xcode: xcode)
			}
		}
		saveXcodes(notify: true)
		reloadPlatforms()
	}

	func removeXcode(xcode: Xcode) {
		var index: Int = 0
		for x in _xcodes {
			if x == xcode {
				_xcodes.remove(at: index)
				saveXcodes(notify: true)
				reloadPlatforms()
				break
			}
			index += 1
		}
	}
}

extension DataSource { /* PLATFORMS */

	func savePlatforms(notify: Bool) {
		if notify {
			Notifications.shared.postNotification(name: .platformDidChanged, object: nil)
		}
	}

	private func checkLocalPlatforms(index: Int, completion: @escaping (_ success: Bool) -> Void) {
		if index < _xcodes.count {
			let xcode = _xcodes[index]
			loadLocal(xcode: xcode) { xcode, platforms, _ in
				self.addPlatforms(platforms: platforms, for: xcode)
				self.checkLocalPlatforms(index: index + 1, completion: completion)
			}
		} else {
			completion(true)
		}
	}

	private func loadLocal(xcode: Xcode, completion: @escaping (_ xcode: Xcode, _ platforms: [Platform], _ error: Error?) -> Void) {
		do {
			var platforms: [Platform] = []
			let appleTVOSDeviceSupport = try FileManager.default.contentsOfDirectory(atPath: "\(xcode.path)/Contents/Developer/Platforms/AppleTVOS.platform/DeviceSupport")
			let iPhoneOSDeviceSupport = try FileManager.default.contentsOfDirectory(atPath: "\(xcode.path)/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport")
			let watchOSDeviceSupport = try FileManager.default.contentsOfDirectory(atPath: "\(xcode.path)/Contents/Developer/Platforms/WatchOS.platform/DeviceSupport")

			for platform in appleTVOSDeviceSupport {
				let path = "\(xcode.path)/Contents/Developer/Platforms/AppleTVOS.platform/DeviceSupport"
				if validate(platform: platform, path: path) {
					let tokens = platform.split(separator: " ")
					let version = String(tokens.first ?? "")
					var build = ""
					if tokens.count > 1 {
						build = String(tokens[1])
						build = build.replacingOccurrences(of: "(", with: "")
						build = build.replacingOccurrences(of: ")", with: "")
					}
					platforms.append(Platform(type: .appleTVOS, status: .local, version: version, build: build, path: path))
				}
			}

			for platform in iPhoneOSDeviceSupport {
				let path = "\(xcode.path)/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport"
				if validate(platform: platform, path: path) {
					let tokens = platform.split(separator: " ")
					let version = String(tokens.first ?? "")
					var build = ""
					if tokens.count > 1 {
						build = String(tokens[1])
						build = build.replacingOccurrences(of: "(", with: "")
						build = build.replacingOccurrences(of: ")", with: "")
					}
					platforms.append(Platform(type: .iPhoneOS, status: .local, version: version, build: build, path: path))
				}
			}

			for platform in watchOSDeviceSupport {
				let path = "\(xcode.path)/Contents/Developer/Platforms/WatchOS.platform/DeviceSupport"
				if validate(platform: platform, path: path) {
					let tokens = platform.split(separator: " ")
					let version = String(tokens.first ?? "")
					var build = ""
					if tokens.count > 1 {
						build = String(tokens[1])
						build = build.replacingOccurrences(of: "(", with: "")
						build = build.replacingOccurrences(of: ")", with: "")
					}
					platforms.append(Platform(type: .watchOS, status: .local, version: version, build: build, path: path))
				}
			}
			completion(xcode, platforms, nil)
		} catch {
			completion(xcode, [], error)
		}
	}

	private func loadCloud(completion: @escaping (_ platforms: [Platform], _ error: Error?) -> Void) {
		guard let url = URL(string: kPlatformsCloudURL) else {
			completion([], NSError(domain: "Invalid URL", code: -1, userInfo: nil))
			return
		}

		let task = URLSession.shared.dataTask(with: url) { data, _, error in
			guard let data = data, let platforms = data.json as? [String: [[String: String]]] else {
				completion([], error)
				return
			}

			var cloudPlatforms: [Platform] = []

			for platform in platforms {
				for entry in platform.value {

					guard
						let type = entry["type"],
						let status = entry["status"],
						let version = entry["version"],
						let build = entry["build"],
						let dmgURL = entry["dmg_url"],
						let signatureURL = entry["signature_url"]
					else {
						return
					}

					guard
						let platformType = PlatformType(rawValue: type),
						let platformStatus = PlatformStatus(rawValue: status)
					else {
						return
					}

					cloudPlatforms.append(Platform(type: platformType, status: platformStatus, version: version, build: build, dmgURL: dmgURL, signatureURL: signatureURL))
				}
			}
			completion(cloudPlatforms, nil)
		}
		task.resume()
	}

	private func validate(platform: String, path: String) -> Bool {
		let dmg = "\(path)/\(platform)/DeveloperDiskImage.dmg"
		let signature = "\(path)/\(platform)/DeveloperDiskImage.dmg.signature"
		return FileManager.default.fileExists(atPath: dmg) && FileManager.default.fileExists(atPath: signature)
	}

	private func addPlatforms(platforms: [Platform], for xcode: Xcode) {
		for platform in platforms {
			if let p = localPlatform(platform: platform) {
				_ = p.installXcode(xcode: xcode)
			} else {
				_ = platform.installXcode(xcode: xcode)
				_localPlatforms.append(platform)
			}
		}
	}

	private func localPlatform(platform: Platform) -> Platform? {
		for p in _localPlatforms where p == platform {
			return p
		}
		return nil
	}
}

import Cocoa

private let kXSwiftFormatReleases = "https://api.github.com/repos/ruiaureliano/X-PlatformManager/releases"

protocol PlatformViewControllerDelegate: AnyObject {
}

class PlatformViewController: NSViewController {

	@IBOutlet weak var platformCollectionView: NSCollectionView!
	@IBOutlet weak var appUpdateButton: NSButton!

	var xcode: Xcode?
	var platforms: [Platform] = []
	var platformType: PlatformType = .iPhoneOS {
		didSet {
			reloadPlatformsData()
		}
	}

	weak var delegate: PlatformViewControllerDelegate?

	var appUpdateVersionName: String?
	var appUpdateVersionButtonURL: String?
	var popover: NSPopover?

	override func viewDidLoad() {
		super.viewDidLoad()

		Notifications.shared.observe(name: .platformDidChanged) { _ in
			self.reloadPlatformsData()
		}
	}

	override func viewWillAppear() {
		super.viewWillAppear()
		checkUpdates()
	}

	func reloadPlatformsData(xcode: Xcode? = nil) {
		if let xcode = xcode {
			self.xcode = xcode
		}
		platforms = DataSource.shared.platforms(for: platformType)
		DispatchQueue.main.async {
			self.platformCollectionView.reloadData()
		}
	}

	private func checkUpdates() {
		guard let url = URL(string: kXSwiftFormatReleases) else { return }

		let request = URLRequest(url: url)
		let task = URLSession.shared.dataTask(with: request) { data, _, _ in
			guard
				let data = data,
				var releases = data.json as? [[String: Any]]
			else {
				return
			}

			releases.sort { dictionary1, dictionary2 in
				let tagName1: String = dictionary1["tag_name"] as? String ?? ""
				let tagName2: String = dictionary2["tag_name"] as? String ?? ""
				return tagName1.compare(tagName2) != .orderedAscending
			}

			guard
				let release = releases.first,
				let name = release["name"] as? String,
				let tagName = release["tag_name"] as? String,
				let publishedAt = release["published_at"] as? String,
				let assets = release["assets"] as? [[String: Any]],
				let asset = assets.first,
				let browserDownloadURL = asset["browser_download_url"] as? String
			else {
				return
			}
			self.validateNewVersion(name: name, tagName: tagName, publishedAt: publishedAt, browserDownloadURL: browserDownloadURL)
		}
		task.resume()
	}

	private func validateNewVersion(name: String, tagName: String, publishedAt: String, browserDownloadURL: String) {
		if let version = Bundle.main.CFBundleShortVersionString {
			switch version.compare(tagName, options: .numeric, range: nil, locale: nil) {
			case .orderedAscending:
				DispatchQueue.main.async {
					debugPrint("UPDATE")
					self.appUpdateVersionName = name
					self.appUpdateVersionButtonURL = browserDownloadURL
					self.appUpdateButton.isEnabled = true
					self.appUpdateButton.isHidden = false
				}
			case .orderedSame:
				break
			case .orderedDescending:
				break
			}
		}
	}
}

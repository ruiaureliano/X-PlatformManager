import Cocoa

enum PlatformCellType: String {
	case cloud
	case local
	case installed
}

enum PlatformCellAppearance: String {
	case dark
	case light
}

extension NSStoryboard.SceneIdentifier {
	static let platformCellView = "PlatformCellView"
}

class PlatformCellView: NSCollectionViewItem {

	@IBOutlet weak var roundedView: PlatformCellViewRoundedView!
	@IBOutlet weak var progressView: PlatformCellViewProgressView!
	@IBOutlet weak var platformView: NSImageView!
	@IBOutlet weak var titleView: NSTextField!
	@IBOutlet weak var actionButton: NSButton!

	private var kvo: NSKeyValueObservation!
	private var theme: PlatformCellAppearance = .light
	var platform: Platform?
	var xcode: Xcode?
	var type: PlatformCellType = .installed
	var version: String = ""

	override func awakeFromNib() {
		super.awakeFromNib()
		kvo = self.roundedView.observe(\.effectiveAppearance, options: .new) { view, _ in
			self.theme = (view.effectiveAppearance.bestMatch(from: [.darkAqua, .vibrantDark]) == nil ? .light : .dark)
			self.updateEffectiveAppearance()
		}
		self.theme = (roundedView.effectiveAppearance.bestMatch(from: [.darkAqua, .vibrantDark]) == nil ? .light : .dark)
		self.updateEffectiveAppearance()
	}

	override var isSelected: Bool {
		didSet {
			roundedView.isSelected = isSelected
			progressView.isSelected = isSelected
			self.updateEffectiveAppearance()
		}
	}

	private func updateEffectiveAppearance() {
		if isSelected {
			if let instance = platform {
				platformView.image = NSImage(named: "\(instance.type.rawValue)-\(type.rawValue)-dark")
			}
			actionButton.image = NSImage(named: "cell-gear-dark")
		} else {
			if let instance = platform {
				platformView.image = NSImage(named: "\(instance.type.rawValue)-\(type.rawValue)-\(theme.rawValue)")
			}
			actionButton.image = NSImage(named: "cell-gear-\(theme.rawValue)")
		}
	}

	func setPlatform(platform: Platform, xcode: Xcode?) {
		self.platform = platform
		self.xcode = xcode
		switch platform.status {
		case .cloud:
			type = .cloud
		case .local:
			if let xcode = xcode, !platform.xcodes.contains(xcode) {
				type = .local
			}
		}

		self.version = platform.version
		if platform.build.count > 0 {
			self.version.append(" (\(platform.build))")
		}
		titleView.stringValue = self.version
		progressView.isHidden = true
		updateEffectiveAppearance()
	}
}

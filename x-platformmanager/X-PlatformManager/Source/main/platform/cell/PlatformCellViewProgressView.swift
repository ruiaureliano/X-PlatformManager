import Cocoa

@IBDesignable class PlatformCellViewProgressView: NSView {

	var isSelected: Bool = false {
		didSet {
			self.needsDisplay = true
		}
	}

	@IBInspectable var progress: Int = 0 {
		didSet {
			self.needsDisplay = true
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)

		let bezier = NSBezierPath(roundedRect: bounds, xRadius: bounds.height / 2, yRadius: bounds.height / 2)
		bezier.addClip()
		NSColor.labelColor.withAlphaComponent(0.1).setFill()
		bezier.fill()

		var _progress: Int = progress
		if progress < 0 {
			_progress = 0
		} else if progress > 100 {
			_progress = 100
		}
		let progressBezier = NSBezierPath(
			roundedRect: CGRect(
				x: bounds.origin.x,
				y: bounds.origin.y,
				width: bounds.size.width * CGFloat(_progress) / 100, height: bounds.size.height),
			xRadius: bounds.height / 2,
			yRadius: bounds.height / 2
		)
		if isSelected {
			NSColor.white.setFill()
		} else {
			NSColor.controlAccentColor.setFill()
		}
		progressBezier.fill()
	}
}

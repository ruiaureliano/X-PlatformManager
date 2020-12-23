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

		let bezier = NSBezierPath(roundedRect: dirtyRect, xRadius: dirtyRect.height / 2, yRadius: dirtyRect.height / 2)
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
				x: dirtyRect.origin.x,
				y: dirtyRect.origin.y,
				width: dirtyRect.size.width * CGFloat(_progress) / 100, height: dirtyRect.size.height),
			xRadius: dirtyRect.height / 2,
			yRadius: dirtyRect.height / 2
		)
		if isSelected {
			NSColor.white.setFill()
		} else {
			NSColor.controlAccentColor.setFill()
		}
		progressBezier.fill()
	}
}

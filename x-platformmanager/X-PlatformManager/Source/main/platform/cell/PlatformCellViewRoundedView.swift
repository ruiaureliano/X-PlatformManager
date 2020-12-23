import Cocoa

@IBDesignable class PlatformCellViewRoundedView: NSView {

	var isSelected: Bool = false {
		didSet {
			self.needsDisplay = true
		}
	}

	override func draw(_ dirtyRect: NSRect) {
		super.draw(dirtyRect)
		let bezier = NSBezierPath(roundedRect: dirtyRect, xRadius: 8, yRadius: 8)
		bezier.addClip()
		if isSelected {
			NSColor.controlAccentColor.setFill()
			bezier.fill()
		}
		NSColor.labelColor.withAlphaComponent(0.10).setStroke()
		bezier.stroke()
	}
}

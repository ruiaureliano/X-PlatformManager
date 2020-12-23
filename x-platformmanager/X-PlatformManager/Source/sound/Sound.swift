import Cocoa

private let kGlassSound = "/System/Library/Sounds/Glass.aiff"
private let kBlowSound = "/System/Library/Sounds/Blow.aiff"
private let kBassoSound = "/System/Library/Sounds/Basso.aiff"

class Sound: NSObject {

	static func glass(function: StaticString = #function, line: Int = #line) {
		DispatchQueue.global(qos: .background).async {
			if let sound = NSSound(contentsOfFile: kGlassSound, byReference: false) {
				sound.play()
			}
		}
	}

	static func blow(function: StaticString = #function, line: Int = #line) {
		DispatchQueue.global(qos: .background).async {
			if let sound = NSSound(contentsOfFile: kBlowSound, byReference: false) {
				sound.play()
			}
		}
	}

	static func basso(function: StaticString = #function, line: Int = #line) {
		DispatchQueue.global(qos: .background).async {
			if let sound = NSSound(contentsOfFile: kBassoSound, byReference: false) {
				sound.play()
			}
		}
	}
}

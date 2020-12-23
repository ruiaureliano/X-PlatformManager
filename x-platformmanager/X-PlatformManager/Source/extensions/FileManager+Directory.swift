import Foundation

extension FileManager {

	func directoryExists(atPath path: String) -> Bool {
		var isDirectory: ObjCBool = false
		let fileExists = self.fileExists(atPath: path, isDirectory: &isDirectory)
		return fileExists && isDirectory.boolValue
	}
}

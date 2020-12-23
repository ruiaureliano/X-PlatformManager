import Cocoa

@main class AppDelegate: NSObject, NSApplicationDelegate {

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		DataSource.shared.validate()
	}

	func applicationWillTerminate(_ aNotification: Notification) {
	}
}

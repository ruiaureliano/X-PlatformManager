import Foundation

typealias DownloaderFailure = (_ error: Error) -> Void
typealias DownloaderSuccess = (_ data: Data) -> Void
typealias DownloaderProgress = (_ progress: Float) -> Void

class Downloader: NSObject {

	static let shared = Downloader()

	private var progress: DownloaderProgress?
	private var success: DownloaderSuccess?
	private var failure: DownloaderFailure?

	func download(url: URL, progress: @escaping DownloaderProgress, success: @escaping DownloaderSuccess, failure: @escaping DownloaderFailure) {

		self.progress = progress
		self.success = success
		self.failure = failure

		let configuration = URLSessionConfiguration.default
		let operationQueue = OperationQueue()
		let session = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)

		let downloadTask = session.downloadTask(with: url)
		downloadTask.resume()
	}

	func download(url: String, progress: @escaping DownloaderProgress, success: @escaping DownloaderSuccess, failure: @escaping DownloaderFailure) {
		guard let url = URL(string: url) else { return }
		download(url: url, progress: progress, success: success, failure: failure)
	}
}

extension Downloader: URLSessionDownloadDelegate {

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
		if let error = downloadTask.error {
			self.failure?(error)
		} else {
			do {
				let data = try Data(contentsOf: location)
				self.success?(data)
			} catch {
				self.failure?(error)
			}
		}
	}

	func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
		self.progress?(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))
	}
}

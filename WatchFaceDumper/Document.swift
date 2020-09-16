import Cocoa
import ZIPFoundation
import Ikemen

class Document: NSDocument {
    var watchface: Watchface?
    private var isLossyReading = false
    private var allowLossyAutosaving = false

    override class var autosavesInPlace: Bool { true } // enables (- Edited) mark, duplicates and reverts

    override func checkAutosavingSafety() throws {
        try super.checkAutosavingSafety()
        if isLossyReading && !allowLossyAutosaving {
            throw NSError(domain: "WatchFaceDumper", code: 0, userInfo: [NSLocalizedDescriptionKey: "watchface file contains some additional information that cannot be handled in this app when saved"])
        }
    }

    override func makeWindowControllers() {
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        let vc = windowController.contentViewController as! ViewController
        vc.document = self
        self.addWindowController(windowController)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        try FileManager.default.unzipItem(at: url, to: tmpURL)
        defer {try? FileManager.default.removeItem(at: tmpURL)}
        try read(from: FileWrapper(url: tmpURL, options: []), ofType: url.pathExtension)
    }

    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        self.watchface = (try Watchface(fileWrapper: fileWrapper)) ※ {
            isLossyReading = !$0.isEqualToFileWrapper(anotherFileWrapper: fileWrapper)
            allowLossyAutosaving = false
        }
    }

    override func data(ofType typeName: String) throws -> Data {
        guard let watchface = watchface else {
            throw EncodingError.invalidValue(self.watchface as Any, EncodingError.Context(codingPath: [], debugDescription: "watchface is nil"))
        }
        let fw = try FileWrapper(watchface: watchface)

        let tmpFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        defer {try? FileManager.default.removeItem(at: tmpFolderURL)}
        try fw.write(to: tmpFolderURL, options: [], originalContentsURL: nil)

        let tmpZipURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        defer {try? FileManager.default.removeItem(at: tmpZipURL)}
        try FileManager.default.zipItem(at: tmpFolderURL, to: tmpZipURL, shouldKeepParent: false)

        return try Data(contentsOf: tmpZipURL)
    }
}


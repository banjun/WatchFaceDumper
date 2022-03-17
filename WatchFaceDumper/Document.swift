import Cocoa
import ZIPFoundation
import Ikemen

class Document: NSDocument {
    var watchface: Watchface
    private var isLossyReading = false
    private var allowLossyAutosaving = false

    override class var autosavesInPlace: Bool { true } // enables (- Edited) mark, duplicates and reverts

    override func checkAutosavingSafety() throws {
        try super.checkAutosavingSafety()
        if isLossyReading && !allowLossyAutosaving {
            throw NSError(domain: "WatchFaceDumper", code: 0, userInfo: [NSLocalizedDescriptionKey: "watchface file contains some additional information that cannot be handled in this app when saved"])
        }
    }

    convenience override init() {
        self.init(photos: ())
    }

    init(photos: Void) {
        watchface = .init(photosWatchface: PhotosWatchface(device_size: 2, position: .top, snapshot: Data(), no_borders_snapshot: Data(), topComplication: nil, bottomComplication: nil, resources: .init(images: .photos(.init(imageList: [])), files: [:])))
        super.init()
    }

    init(portrait: Void) {
        watchface = .init(portraitWatchface: PortraitWatchface(device_size: 2, style: .style3, snapshot: Data(), no_borders_snapshot: Data(), dateComplication: nil, bottomComplication: nil, resources: .init(images: .init(imageList: []), files: [:])))
        super.init()
    }

    override func makeWindowControllers() {
        addWindowController(WindowController(document: self))
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        try FileManager.default.unzipItem(at: url, to: tmpURL)
        defer {try? FileManager.default.removeItem(at: tmpURL)}
        try read(from: FileWrapper(url: tmpURL, options: []), ofType: url.pathExtension)
    }

    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        do {
            self.watchface = (try Watchface(fileWrapper: fileWrapper)) ※ {
                isLossyReading = !$0.isEqualToFileWrapper(anotherFileWrapper: fileWrapper)
                allowLossyAutosaving = false
            }
        } catch {
            NSLog("%@", "error reading \(fileWrapper): \(String(describing: error))")
            throw NSError(domain: (error as NSError).domain,code: (error as NSError).code, userInfo: (error as NSError).userInfo ※ {$0[NSLocalizedFailureReasonErrorKey] = "\n\nError Report:\n" + String(describing: error)})
        }
    }

    override func data(ofType typeName: String) throws -> Data {
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

extension Document: NSPasteboardWriting {
    func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        return [.init(rawValue: "com.apple.watchface")]
    }

    func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        fileType.flatMap {try? data(ofType: $0) as NSData}
    }
}

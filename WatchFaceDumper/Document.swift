import Cocoa
import ZIPFoundation

class Document: NSDocument {
    var watchface: Watchface?

    override class var autosavesInPlace: Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
        let storyboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        let windowController = storyboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier("Document Window Controller")) as! NSWindowController
        let vc = windowController.contentViewController as! ViewController
        vc.watchface = watchface
        self.addWindowController(windowController)
    }

    override func read(from url: URL, ofType typeName: String) throws {
        let tmpURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString)
        try FileManager.default.unzipItem(at: url, to: tmpURL)
        defer {try? FileManager.default.removeItem(at: tmpURL)}
        try read(from: FileWrapper(url: tmpURL, options: []), ofType: url.pathExtension)
    }

    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        NSLog("%@", "\(fileWrapper.debugDescription)")
        NSLog("%@", "\(String(describing: fileWrapper.fileWrappers))")

        guard let metadata_json = fileWrapper.fileWrappers?["metadata.json"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "metadata.json not found"))
        }
        let metadata = try JSONDecoder().decode(Watchface.Metadata.self, from: metadata_json)

        guard let face_json = fileWrapper.fileWrappers?["face.json"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "face.json not found"))
        }
        let face = try JSONDecoder().decode(Watchface.Face.self, from: face_json)

        guard let snapshot = fileWrapper.fileWrappers?["snapshot.png"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "snapshot.png not found"))
        }

        guard let no_borders_snapshot = fileWrapper.fileWrappers?["no_borders_snapshot.png"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "no_borders_snapshot.png not found"))
        }

        let device_border_snapshot = fileWrapper.fileWrappers?["device_border_snapshot.png"]?.regularFileContents

        guard let resources = fileWrapper.fileWrappers?["Resources"]?.fileWrappers else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Resources/ not found"))
        }

        guard let resources_metadata_plist = resources["Images.plist"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Images.plist not found"))
        }
        let resources_metadata = try PropertyListDecoder().decode(Watchface.Resources.Metadata.self, from: resources_metadata_plist)

        self.watchface = Watchface(
            metadata: metadata,
            face: face,
            snapshot: snapshot,
            no_borders_snapshot: no_borders_snapshot,
            device_border_snapshot: device_border_snapshot,
            resources: Watchface.Resources(images: resources_metadata, files: resources_metadata.imageList.map {$0.imageURL}.reduce(into: [:]) {$0[$1] = resources[$1]?.regularFileContents})
        )
    }

    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        throw NSError()
//        FileWrapper(
//            directoryWithFileWrappers: [
//                "metadata.json": FileWrapper(regularFileWithContents: Data())
//            ])
    }
}


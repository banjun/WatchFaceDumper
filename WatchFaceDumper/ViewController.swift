import Cocoa
import NorthLayout
import Ikemen
import AVKit

final class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    private let snapshot = NSImageView()
    private let snapshotLabel = NSTextField(labelWithString: "snapshot")
    private let noBordersSnapshot = NSImageView()
    private let noBordersSnapshotLabel = NSTextField(labelWithString: "no_borders_snapshot")
    private lazy var imageListTableView: NSTableView = .init(frame: .zero) ※ {
        $0.delegate = self
        $0.dataSource = self
        $0.usesAutomaticRowHeights = true
        $0.addTableColumn(.init(identifier: .init(rawValue: "ImageItem")) ※ {$0.title = "Resources/Images"})
    }
    private lazy var addImageButton: NSButton = .init(title: "Add Image", target: self, action: #selector(addImage(_:)))
    private lazy var removeImageButton: NSButton = .init(title: "Remove Image", target: self, action: #selector(removeImage(_:)))
    private let complicationsTopLabel = NSTextField(labelWithString: "complications.top")
    private let complicationsBottomLabel = NSTextField(labelWithString: "complications.bottom")

    override func viewDidLoad() {
        super.viewDidLoad()

        let autolayout = view.northLayoutFormat(["pp": 16], [
            "snapshot": snapshot ※ {
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
            },
            "snapshotLabel": snapshotLabel,
            "noBordersSnapshot": noBordersSnapshot ※ {
                $0.setContentHuggingPriority(.required, for: .horizontal)
                $0.setContentHuggingPriority(.required, for: .vertical)
            },
            "noBordersSnapshotLabel": noBordersSnapshotLabel,
            "imageList": NSScrollView() ※ { sv in
                sv.hasVerticalScroller = true
                sv.documentView = imageListTableView
            },
            "addImage": addImageButton,
            "removeImage": removeImageButton,
            "complicationsTop": complicationsTopLabel,
            "complicationsBottom": complicationsBottomLabel,
            "spacer1": MinView(),
            "spacer2": MinView(),
        ])
        autolayout("H:|-pp-[snapshot]-pp-[noBordersSnapshot]-pp-[imageList(>=240)]|")
        autolayout("H:[noBordersSnapshotLabel]-(>=pp)-[imageList]")
        autolayout("H:|-pp-[complicationsTop]-pp-[imageList]")
        autolayout("H:|-pp-[complicationsBottom]-pp-[imageList]")
        autolayout("H:[noBordersSnapshot]-pp-[addImage]-[removeImage(addImage)]-|")
        autolayout("V:|-(>=pp)-[snapshot][spacer1(>=pp)][snapshotLabel]-(>=pp)-[complicationsTop]")
        autolayout("V:|-(>=pp)-[noBordersSnapshot][spacer2(>=pp)][noBordersSnapshotLabel]-(>=pp)-[complicationsTop]")
        autolayout("V:[complicationsTop]-[complicationsBottom]-pp-|")
        autolayout("V:|[imageList]-[addImage]-pp-|")
        autolayout("V:|[imageList]-[removeImage]-pp-|")

        snapshot.centerYAnchor.constraint(equalTo: noBordersSnapshot.centerYAnchor).isActive = true

        snapshot.centerXAnchor.constraint(equalTo: snapshotLabel.centerXAnchor).isActive = true
        noBordersSnapshot.centerXAnchor.constraint(equalTo: noBordersSnapshotLabel.centerXAnchor).isActive = true
    }

    var document: Document? {
        didSet {
            reloadDocument()
        }
    }

    func reloadDocument() {
        let watchface = document?.watchface
        // NSLog("%@", "\(watchface)")
        snapshot.image = watchface.flatMap {NSImage(data: $0.snapshot)}
        noBordersSnapshot.image = watchface.flatMap {NSImage(data: $0.no_borders_snapshot)}

        let resources = watchface?.resources
        imageItems = (resources.flatMap {r in r.images.imageList.map {(r.files[$0.imageURL], r.files[$0.irisVideoURL])}} ?? [])
            .map {ImageItem(image: $0.0.flatMap {NSImage(data: $0)}, movie: $0.1)}

        complicationsTopLabel.stringValue = "complications.top: " + (watchface?.metadata.complications_names.top ?? "") + " " +  (watchface?.metadata.complication_sample_templates.top?.sampleText.map {"(\($0))"} ?? "" as String)
        complicationsBottomLabel.stringValue = "complications.bottom: " + (watchface?.metadata.complications_names.bottom ?? "") + " " + (watchface?.metadata.complication_sample_templates.bottom?.sampleText.map {"(\($0))"} ?? "" as String)
    }

    typealias ImageItem = ImageItemRowView.ImageItem
    var imageItems: [ImageItem] = [] {
        didSet { imageListTableView.reloadData() }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {imageItems.count}
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {nil}
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        ImageItemRowView(item: imageItems[row]) ※ {
            $0.imageDidChange = { [weak self] image in
                guard let self = self, let watchface = self.document?.watchface else { return }
                self.document?.watchface = watchface ※ { watchface in
                    let imageURL = watchface.resources.images.imageList[row].imageURL
                    let jpeg = image?.tiffRepresentation.flatMap {NSBitmapImageRep(data: $0)}?.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
                    watchface.resources.files[imageURL] = jpeg
                    // TODO: resize
                }
                self.reloadDocument()
            }
            $0.movieDidChange = { [weak self] movie in
                guard let self = self, let watchface = self.document?.watchface else { return }
                self.document?.watchface = watchface ※ { watchface in
                    let irisVideoURL = watchface.resources.images.imageList[row].irisVideoURL
                    watchface.resources.files[irisVideoURL] = movie
                    watchface.resources.images.imageList[row].isIris = movie != nil
                    // TODO: re-compress: should be less than 3 secs?
                    // TODO: update duration metadata
                }
                self.reloadDocument()
            }
        }
    }

    @IBAction func addImage(_ sender: Any?) {
        NSLog("%@", "not yet implemented")
    }

    @IBAction func removeImage(_ sender: Any?) {
        guard case 0..<imageItems.count = imageListTableView.selectedRow, let watchface = document?.watchface else { return }
        document?.watchface = watchface ※ { watchface in
            let removed = watchface.resources.images.imageList.remove(at: imageListTableView.selectedRow)
            [removed.imageURL, removed.irisVideoURL].forEach {
                watchface.resources.files.removeValue(forKey: $0)
            }
        }
        reloadDocument()
    }
}

extension Watchface.Metadata.ComplicationSampleTemplate.ComplicationTemplate {
    var sampleText: String? {
        switch self {
        case .utilitarianSmallFlat(let t): return t.textProvider.sampleText
        case .utilitarianLargeFlat(let t): return t.textProvider.sampleText
        }
    }
}
extension Watchface.Metadata.ComplicationSampleTemplate.CLKTextProvider {
    var sampleText: String? {
        switch self {
        case .date(let p):
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd"
            return df.string(from: p.date)
        case .time(let p):
            let df = DateFormatter()
            df.dateFormat = "HH:mm"
            return df.string(from: p.date)
        case .compound(let p):
            return zip(p.format_segments, p.textProviders.map {$0.sampleText ?? ""}).map {$0 + $1}.joined() + (p.format_segments.last ?? "")
        case .simple(let p):
            return p.text
        }
    }
}

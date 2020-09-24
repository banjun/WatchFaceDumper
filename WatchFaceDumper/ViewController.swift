import Cocoa
import NorthLayout
import Ikemen
import AVKit

final class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSplitViewDelegate {
    var document: Document {
        didSet {
            reloadDocument()
        }
    }

    private let faceTypeLabel = NSTextField(labelWithString: "")
    private let snapshotsStackView = NSStackView() ※ {
        $0.orientation = .horizontal
        $0.alignment = .centerY
    }
    private let snapshot = NSImageView()
    private let snapshotLabel = NSTextField(labelWithString: "snapshot") ※ {
        $0.alignment = .center
    }
    private let noBordersSnapshot = NSImageView()
    private let noBordersSnapshotLabel = NSTextField(labelWithString: "no_borders_snapshot") ※ {
        $0.alignment = .center
    }
    private lazy var metadataViewModel: MetadataViewModel = .init() ※ {
        $0.reloadAndExpand = { [weak self] in
            self?.metadataOutlineView.reloadData()
            self?.metadataOutlineView.expandItem(nil, expandChildren: true)
        }
    }
    private lazy var metadataOutlineView: NSOutlineView = .init() ※ {
        $0.delegate = metadataViewModel
        $0.dataSource = metadataViewModel
        $0.addTableColumn(.init(identifier: .init(rawValue: "Metadata")) ※ {$0.title = "metadta.json & face.json"})
    }
    private lazy var imageListSplitView = NSSplitView() ※ { split in
        split.delegate = self
        split.isVertical = true
        split.addArrangedSubview(NSScrollView() ※ { sv in
            sv.hasVerticalScroller = true
            sv.documentView = imageListTableView
        })
        split.addArrangedSubview(NSScrollView() ※ { sv in
            sv.hasVerticalScroller = true
            sv.documentView = imageListOutlineView
        })
    }
    private lazy var imageListTableView: NSTableView = .init(frame: .zero) ※ {
        $0.delegate = self
        $0.dataSource = self
        $0.usesAutomaticRowHeights = true
        $0.addTableColumn(.init(identifier: .init(rawValue: "ImageItem")) ※ {$0.title = "Resources/"})
    }
    private(set) lazy var imageListOutlineViewModel = ImageListOutlineViewModel() ※ {
        $0.reloadAndExpand = { [weak self] in
            self?.imageListOutlineView.reloadData()
            self?.imageListOutlineView.expandItem(nil, expandChildren: true)
        }
    }
    private(set) lazy var imageListOutlineView: NSOutlineView = .init() ※ {
        $0.delegate = imageListOutlineViewModel
        $0.dataSource = imageListOutlineViewModel
        $0.addTableColumn(.init(identifier: .init(rawValue: "ImageList")) ※ {$0.title = "Resources/Images.plist"})
    }
    private let complicationsTopLabel = NSTextField(labelWithString: "complications.top")
    private let complicationsBottomLabel = NSTextField(labelWithString: "complications.bottom")

    init(document: Document) {
        self.document = document
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let autolayout = view.northLayoutFormat(["pp": 16], [
            "type": faceTypeLabel,
            "snapshots": snapshotsStackView ※ {
                $0.addArrangedSubview(NSView() ※ {
                    let autolayout = $0.northLayoutFormat([:], [
                        "snapshot": snapshot ※ {
                            $0.setContentHuggingPriority(.required, for: .horizontal)
                            $0.setContentHuggingPriority(.required, for: .vertical)
                        },
                        "label": snapshotLabel
                    ])
                    autolayout("H:|[snapshot]|")
                    autolayout("H:|[label]|")
                    autolayout("V:|[snapshot]-[label]|")
                })
                $0.addArrangedSubview(NSView() ※ {
                    let autolayout = $0.northLayoutFormat([:], [
                        "snapshot": noBordersSnapshot ※ {
                            $0.setContentHuggingPriority(.required, for: .horizontal)
                            $0.setContentHuggingPriority(.required, for: .vertical)
                        },
                        "label": noBordersSnapshotLabel
                    ])
                    autolayout("H:|[snapshot]|")
                    autolayout("H:|[label]|")
                    autolayout("V:|[snapshot]-[label]|")
                })
            },
            "metadata": NSScrollView() ※ { sv in
                sv.hasVerticalScroller = true
                sv.documentView = metadataOutlineView
            },
            "imageListSplitView": imageListSplitView,
            "complicationsTop": complicationsTopLabel,
            "complicationsBottom": complicationsBottomLabel,
        ])
        autolayout("H:|-pp-[type]-pp-[imageListSplitView]")
        autolayout("H:|-pp-[snapshots]-pp-[imageListSplitView(>=400)]|")
        autolayout("H:|-pp-[metadata]-pp-[imageListSplitView]")
        autolayout("H:|-pp-[complicationsTop]-pp-[imageListSplitView]")
        autolayout("H:|-pp-[complicationsBottom]-pp-[imageListSplitView]")
        autolayout("V:|-pp-[type]-[snapshots]-pp-[metadata(>=200)]-[complicationsTop]-[complicationsBottom]-pp-|")
        autolayout("V:|[imageListSplitView]|")

        reloadDocument()
    }

    func reloadDocument() {
        let watchface = document.watchface
        // NSLog("%@", "\(watchface)")

        let faceType = watchface.face.face_type.rawValue
        faceTypeLabel.stringValue = faceType.first!.uppercased() + faceType.dropFirst() + " watch face"

        snapshot.image = NSImage(data: watchface.snapshot)
        noBordersSnapshot.image = NSImage(data: watchface.no_borders_snapshot)

        metadataViewModel.setWatchface(watchface)

        let resources = watchface.resources
        imageItems = resources.images.imageList
            .map {(resources.files[$0.imageURL], resources.files[$0.irisVideoURL])}
            .map {ImageItem(image: $0.0.flatMap {NSImage(data: $0)}, movie: $0.1)}

        imageListOutlineViewModel.setWatchface(watchface)

        complicationsTopLabel.stringValue = "complications.top: " + (watchface.metadata.complications_names.top ?? "" as String) + " " +  (watchface.metadata.complication_sample_templates.top?.sampleText.map {"(\($0))"} ?? "")
        complicationsBottomLabel.stringValue = "complications.bottom: " + (watchface.metadata.complications_names.bottom ?? "" as String) + " " + (watchface.metadata.complication_sample_templates.bottom?.sampleText.map {"(\($0))"} ?? "")
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
                guard let self = self else { return }
                self.document.watchface = self.document.watchface ※ { watchface in
                    let imageURL = watchface.resources.images.imageList[row].imageURL
                    let jpeg = image?.tiffRepresentation.flatMap {NSBitmapImageRep(data: $0)}?.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
                    watchface.resources.files[imageURL] = jpeg
                    // TODO: resize
                    watchface.resources.images.imageList[row].cropX = 0
                    watchface.resources.images.imageList[row].cropY = 0
                    watchface.resources.images.imageList[row].cropW = Double(image?.size.width ?? 0)
                    watchface.resources.images.imageList[row].cropH = Double(image?.size.height ?? 0)
                    watchface.resources.images.imageList[row].originalCropX = 0
                    watchface.resources.images.imageList[row].originalCropY = 0
                    watchface.resources.images.imageList[row].originalCropW = Double(image?.size.width ?? 0)
                    watchface.resources.images.imageList[row].originalCropH = Double(image?.size.height ?? 0)
                }
                self.reloadDocument()
            }
            $0.movieDidChange = { [weak self] movie in
                guard let self = self else { return }
                self.document.watchface = self.document.watchface ※ { watchface in
                    let irisVideoURL = watchface.resources.images.imageList[row].irisVideoURL
                    watchface.resources.files[irisVideoURL] = movie
                    watchface.resources.images.imageList[row].isIris = movie != nil
                    watchface.resources.images.imageList[row].irisDuration = 2.3
                    watchface.resources.images.imageList[row].irisStillDisplayTime = 1.4
                    // TODO: re-compress: should be less than 3 secs?
                    // TODO: update duration metadata

                }
                self.reloadDocument()
            }
        }
    }

    func splitView(_ splitView: NSSplitView, constrainMinCoordinate proposedMinimumPosition: CGFloat, ofSubviewAt dividerIndex: Int) -> CGFloat {
        switch splitView.arrangedSubviews[dividerIndex] {
        case imageListTableView.enclosingScrollView: return 240
        case imageListOutlineView.enclosingScrollView: return 0
        default: return 0
        }
    }

    @IBAction func addImage(_ sender: Any?) {
        document.watchface = document.watchface ※ { watchface in
            // TODO: get image and compress
            let imageData: Data? = Data()
            let movieData: Data? = nil

            let filenameBase = UUID().uuidString

            let item = Watchface.Resources.Metadata.Item(
                topAnalysis: .init(bgBrightness: 0, bgHue: 0, bgSaturation: 0, coloredText: false, complexBackground: false, shadowBrightness: 0, shadowHue: 0, shadowSaturation: 0, textBrightness: 0, textHue: 0, textSaturation: 0),
                leftAnalysis: .init(bgBrightness: 0, bgHue: 0, bgSaturation: 0, coloredText: false, complexBackground: false, shadowBrightness: 0, shadowHue: 0, shadowSaturation: 0, textBrightness: 0, textHue: 0, textSaturation: 0),
                bottomAnalysis: .init(bgBrightness: 0, bgHue: 0, bgSaturation: 0, coloredText: false, complexBackground: false, shadowBrightness: 0, shadowHue: 0, shadowSaturation: 0, textBrightness: 0, textHue: 0, textSaturation: 0),
                rightAnalysis: .init(bgBrightness: 0, bgHue: 0, bgSaturation: 0, coloredText: false, complexBackground: false, shadowBrightness: 0, shadowHue: 0, shadowSaturation: 0, textBrightness: 0, textHue: 0, textSaturation: 0),
                imageURL: "\(filenameBase).jpg",
                irisDuration: 0,
                irisStillDisplayTime: 0,
                irisVideoURL: "\(filenameBase).mov",
                isIris: movieData != nil,
                localIdentifier: "",
                modificationDate: Date(),
                cropH: 0,
                cropW: 0,
                cropX: 0,
                cropY: 0,
                originalCropH: 0,
                originalCropW: 0,
                originalCropX: 0,
                originalCropY: 0)
            watchface.resources.images.imageList.append(item)
            watchface.resources.files[item.imageURL] = imageData
            watchface.resources.files[item.irisVideoURL] = movieData
        }
        reloadDocument()
    }

    @IBAction func removeImage(_ sender: Any?) {
        guard case 0..<imageItems.count = imageListTableView.selectedRow else { return }
        document.watchface = document.watchface ※ { watchface in
            let removed = watchface.resources.images.imageList.remove(at: imageListTableView.selectedRow)
            [removed.imageURL, removed.irisVideoURL].forEach {
                watchface.resources.files.removeValue(forKey: $0)
            }
        }
        reloadDocument()
    }
}

extension Watchface.Metadata.ComplicationTemplate {
    var sampleText: String? {
        switch self {
        case .utilitarianSmallFlat(let t): return t.textProvider.sampleText
        case .utilitarianLargeFlat(let t): return t.textProvider.sampleText
        case .circularSmallSimpleText(let t): return t.textProvider.sampleText
        case .circularSmallSimpleImage: return "image"
        }
    }
}
extension Watchface.Metadata.CLKTextProvider {
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

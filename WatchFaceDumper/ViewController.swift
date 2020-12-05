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
        $0.distribution = .fillEqually
    }
    private let snapshot = NSImageView()
    private let snapshotLabel = NSTextField(labelWithString: "snapshot") ※ {
        $0.alignment = .center
    }
    private let noBordersSnapshot = NSImageView()
    private let noBordersSnapshotLabel = NSTextField(labelWithString: "no_borders_snapshot") ※ {
        $0.alignment = .center
        $0.lineBreakMode = .byTruncatingTail
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
        if #available(macOS 11, *) {
            $0.rowHeight = 18 // Big Sur default is ugly high
        }
        $0.addTableColumn(.init(identifier: .init(rawValue: "Metadata")) ※ {$0.title = "metadta.json & face.json & complicationData/"})
    }
    private lazy var imageListSplitView = NSSplitView() ※ { split in
        split.delegate = self
        split.isVertical = true
        split.addArrangedSubview(NSScrollView() ※ { sv in
            sv.hasHorizontalScroller = true
            sv.hasVerticalScroller = true
            sv.documentView = imageListTableView
        })
        split.addArrangedSubview(NSScrollView() ※ { sv in
            sv.hasHorizontalScroller = true
            sv.hasVerticalScroller = true
            sv.documentView = imageListOutlineView
        })
    }
    private lazy var imageListTableView: NSTableView = .init(frame: .zero) ※ {
        $0.delegate = self
        $0.dataSource = self
        $0.usesAutomaticRowHeights = true
        if #available(OSX 11.0, *) {
            $0.style = .plain
        }
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
        if #available(macOS 11, *) {
            $0.rowHeight = 18 // Big Sur default is ugly high
        }
        $0.addTableColumn(.init(identifier: .init(rawValue: "ImageList")) ※ {$0.title = "Resources/Images.plist"})
    }
    private let complicationsTopLabel = NSTextField() ※ {
        $0.stringValue = "complications.top"
        $0.drawsBackground = false
        $0.isBezeled = false
        $0.isEditable = false
        $0.maximumNumberOfLines = 0
        $0.setContentCompressionResistancePriority(.init(rawValue: 9), for: .horizontal)
    }
    private let complicationsBottomLabel = NSTextField() ※ {
        $0.stringValue = "complications.bottom"
        $0.drawsBackground = false
        $0.isBezeled = false
        $0.isEditable = false
        $0.maximumNumberOfLines = 0
        $0.setContentCompressionResistancePriority(.init(rawValue: 9), for: .horizontal)
    }

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
                        "snapshot": snapshot,
                        "label": snapshotLabel ※ {
                            $0.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
                        }
                    ])
                    autolayout("H:|[snapshot]|")
                    autolayout("H:|[label]|")
                    autolayout("V:|[snapshot]-[label]|")
                })
                $0.addArrangedSubview(NSView() ※ {
                    let autolayout = $0.northLayoutFormat([:], [
                        "snapshot": noBordersSnapshot,
                        "label": noBordersSnapshotLabel ※ {
                            $0.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
                        }
                    ])
                    autolayout("H:|[snapshot]|")
                    autolayout("H:|[label]|")
                    autolayout("V:|[snapshot]-[label]|")
                })
                
                let snapshotDefaultSize = CGSize(width: 486, height: 591)
                let noBordersSnapshotDefaultSize = CGSize(width: 623, height: 757)
                snapshot.heightAnchor.constraint(equalTo: snapshot.widthAnchor, multiplier: snapshotDefaultSize.height / snapshotDefaultSize.width).isActive = true
                noBordersSnapshot.heightAnchor.constraint(equalTo: noBordersSnapshot.widthAnchor, multiplier: noBordersSnapshotDefaultSize.height / noBordersSnapshotDefaultSize.width).isActive = true
            },
            "metadata": NSScrollView() ※ { sv in
                sv.hasHorizontalScroller = true
                sv.hasVerticalScroller = true
                sv.documentView = metadataOutlineView
            },
            "imageListSplitView": imageListSplitView,
            "complicationsTop": complicationsTopLabel,
            "complicationsBottom": complicationsBottomLabel,
        ])
        autolayout("H:|-pp-[type]-pp-[imageListSplitView]")
        autolayout("H:|-pp-[snapshots]-pp-[imageListSplitView(>=400)]|")
        autolayout("H:|-pp-[metadata(256)]-pp-[imageListSplitView]")
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
        snapshot.imageFrameStyle = snapshot.image.map {_ in .none} ?? .grayBezel
        noBordersSnapshot.image = NSImage(data: watchface.no_borders_snapshot)
        noBordersSnapshot.imageFrameStyle = snapshot.image.map {_ in .none} ?? .grayBezel

        metadataViewModel.setWatchface(watchface)

        imageItems = watchface.resources.map { resources in
            resources.images.imageList
                .map {(resources.files[$0.imageURL], resources.files[$0.irisVideoURL])}
                .map {ImageItem(image: $0.0.flatMap {NSImage(data: $0)}, movie: $0.1)}
        } ?? []

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
                    guard let imageURL = watchface.resources?.images.imageList[row].imageURL else { return }
                    let jpeg = image?.tiffRepresentation.flatMap {NSBitmapImageRep(data: $0)}?.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
                    watchface.resources?.files[imageURL] = jpeg
                    // TODO: resize
                    watchface.resources?.images.imageList[row].cropX = 0
                    watchface.resources?.images.imageList[row].cropY = 0
                    watchface.resources?.images.imageList[row].cropW = Double(image?.size.width ?? 0)
                    watchface.resources?.images.imageList[row].cropH = Double(image?.size.height ?? 0)
                    watchface.resources?.images.imageList[row].originalCropX = 0
                    watchface.resources?.images.imageList[row].originalCropY = 0
                    watchface.resources?.images.imageList[row].originalCropW = Double(image?.size.width ?? 0)
                    watchface.resources?.images.imageList[row].originalCropH = Double(image?.size.height ?? 0)
                }
                self.reloadDocument()
            }
            $0.movieDidChange = { [weak self] movie in
                guard let self = self else { return }
                self.document.watchface = self.document.watchface ※ { watchface in
                    guard let irisVideoURL = watchface.resources?.images.imageList[row].irisVideoURL else { return }
                    watchface.resources?.files[irisVideoURL] = movie
                    watchface.resources?.images.imageList[row].isIris = movie != nil
                    watchface.resources?.images.imageList[row].irisDuration = 2.3
                    watchface.resources?.images.imageList[row].irisStillDisplayTime = 1.4
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
            watchface.resources?.images.imageList.append(item)
            watchface.resources?.files[item.imageURL] = imageData
            watchface.resources?.files[item.irisVideoURL] = movieData
        }
        reloadDocument()
    }

    @IBAction func removeImage(_ sender: Any?) {
        guard case 0..<imageItems.count = imageListTableView.selectedRow else { return }
        document.watchface = document.watchface ※ { watchface in
            guard let removed = watchface.resources?.images.imageList.remove(at: imageListTableView.selectedRow) else { return }
            [removed.imageURL, removed.irisVideoURL].forEach {
                watchface.resources?.files.removeValue(forKey: $0)
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
        case .graphicCornerGaugeText: return "gauge"
        case .graphicCornerTextImage(let t): return t.textProvider.sampleText
        case .graphicBezelCircularText(let t): return t.textProvider.sampleText
        case .graphicCircularImage: return "image"
        case .graphicCircularOpenGaugeSimpleText(let t): return "center: \(t.centerTextProvider.sampleText ?? "(null)"), bottom: \(t.bottomTextProvider.sampleText ?? "(null)")"
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

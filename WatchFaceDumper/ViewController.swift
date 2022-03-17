import Cocoa
import NorthLayout
import Ikemen
import AVKit
import Combine
import CoreGraphics

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

    private var cancellables: Set<AnyCancellable> = []

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

        let faceTypeName: String = {
            switch watchface.face.face_type {
            case .bundle where watchface.face.bundle_id == .comAppleNTKUltraCubeFaceBundle: return "Portrait"
            default: return watchface.face.face_type.rawValue
            }
        }()
        faceTypeLabel.stringValue = faceTypeName.first!.uppercased() + faceTypeName.dropFirst() + " watch face"

        snapshot.image = NSImage(data: watchface.snapshot)
        snapshot.imageFrameStyle = snapshot.image.map {_ in .none} ?? .grayBezel
        noBordersSnapshot.image = NSImage(data: watchface.no_borders_snapshot)
        noBordersSnapshot.imageFrameStyle = snapshot.image.map {_ in .none} ?? .grayBezel

        metadataViewModel.setWatchface(watchface)

        resourceItems = watchface.resources.map { resources in
            switch resources.images {
            case .photos(let v): return .photos(
                v.imageList
                    .map {(resources.files[$0.imageURL], resources.files[$0.irisVideoURL])}
                    .map {.init(image: $0.0.flatMap {NSImage(data: $0)}, movie: $0.1.map {($0, nil)})})
            case .ultraCube(let v): return .ultraCube(
                v.imageList
                    .map {(resources.files[$0.baseImageURL],
                           $0.backgroundImageURL.flatMap {resources.files[$0]},
                           $0.maskImageURL.flatMap {resources.files[$0]})}
                    .map {.init(baseImage: $0.0.flatMap {NSImage(data: $0)},
                                backImage: $0.1.flatMap {NSImage(data: $0)},
                                maskImage: $0.2.flatMap {NSImage(data: $0)})})
            }
        } ?? .photos([])

        imageListOutlineViewModel.setWatchface(watchface)

        complicationsTopLabel.stringValue = "complications.top: " + (watchface.metadata.complications_names.top ?? "" as String) + " " +  (watchface.metadata.complication_sample_templates.top?.sampleText.map {"(\($0))"} ?? "")
        complicationsBottomLabel.stringValue = "complications.bottom: " + (watchface.metadata.complications_names.bottom ?? "" as String) + " " + (watchface.metadata.complication_sample_templates.bottom?.sampleText.map {"(\($0))"} ?? "")
    }

    var resourceItems: ResourceItems = .photos([]) {
        didSet {
            guard resourceItems != oldValue else { return }
            imageListTableView.reloadData()
        }
    }
    enum ResourceItems: Equatable {
        case photos([ImageItemRowView.ImageItem])
        case ultraCube([UltraCubeImageItemRowView.ImageItem])

        var count: Int {
            switch self {
            case .photos(let items): return items.count
            case .ultraCube(let items): return items.count
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {resourceItems.count}
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {nil}
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        switch resourceItems {
        case .photos(let items):
            return ImageItemRowView(item: items[row]) ※ {
                $0.imageDidChange = { [weak self] image in
                    guard let self = self else { return }
                    self.document.watchface = self.document.watchface ※ { watchface in
                        guard let resources = watchface.resources else { return }
                        let jpeg = image?.tiffRepresentation.flatMap {NSBitmapImageRep(data: $0)}?.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
                        watchface.resources = resources ※ { resources in
                            switch resources.images {
                            case .photos(let v):
                                resources.files[v.imageList[row].imageURL] = jpeg
                                resources.images = .photos(v ※ {
                                    // TODO: resize
                                    $0.imageList[row].cropX = 0
                                    $0.imageList[row].cropY = 0
                                    $0.imageList[row].cropW = Double(image?.size.width ?? 0)
                                    $0.imageList[row].cropH = Double(image?.size.height ?? 0)
                                    $0.imageList[row].originalCropX = 0
                                    $0.imageList[row].originalCropY = 0
                                    $0.imageList[row].originalCropW = Double(image?.size.width ?? 0)
                                    $0.imageList[row].originalCropH = Double(image?.size.height ?? 0)
                                })
                            case .ultraCube:
                                break
                            }
                        }
                    }
                    self.reloadDocument()
                }
                $0.movieDidChange = { [weak self] in
                    guard let self = self else { return }
                    let (movie, duration) = ($0?.data, $0?.duration.flatMap {$0 > 0 ? $0 : nil})
                    self.document.watchface = self.document.watchface ※ { watchface in
                        switch watchface.resources?.images {
                        case .photos(let v):
                            watchface.resources?.files[v.imageList[row].irisVideoURL] = movie
                            watchface.resources?.images = .photos(v ※ {
                                $0.imageList[row].isIris = movie != nil
                                $0.imageList[row].irisDuration = duration ?? 3.0
                                $0.imageList[row].irisStillDisplayTime = (duration ?? 3.0) - 0.1
                                // NOTE: 3 secs in 30fps is best for watchface resources that is cropped & created as watchface by iOS
                                // TODO: re-compress: should be less than 3 secs?
                                // TODO: update duration metadata
                            })
                        case .ultraCube?, nil:
                            break
                        }
                    }
                    self.reloadDocument()
                }
            }
        case .ultraCube(let items):
            return UltraCubeImageItemRowView(item: items[row]) ※ {
                $0.$item.scan((UltraCubeImageItemRowView.ImageItem?, UltraCubeImageItemRowView.ImageItem)?.none) {($0?.1, $1)}.compactMap {$0}.sink { old, new in
                    let base = new.baseImage?.tiffRepresentation.flatMap {NSBitmapImageRep(data: $0)}?.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
                    let back = new.backImage?.tiffRepresentation.flatMap {NSBitmapImageRep(data: $0)}?.representation(using: .jpeg, properties: [.compressionFactor: 0.95])
                    let maskPng = new.maskImage.flatMap { image -> Data? in
                        let width = Int(image.size.width)
                        let height = Int(image.size.height)
                        guard let rep = NSBitmapImageRep(
                                bitmapDataPlanes: nil,
                                pixelsWide: width,
                                pixelsHigh: height,
                                bitsPerSample: 8, // mask png should be 8-bit grayscale
                                samplesPerPixel: 1,
                                hasAlpha: false, // mask png should not have alpha channel
                                isPlanar: false, // suitable to be NSGraphicsContext.current
                                colorSpaceName: .calibratedWhite,
                                bytesPerRow: width,
                                bitsPerPixel: 8) else { return nil }
                        NSGraphicsContext.saveGraphicsState()
                        defer { NSGraphicsContext.restoreGraphicsState() }
                        NSGraphicsContext.current = .init(bitmapImageRep: rep)
                        image.draw(in: NSRect(origin: .zero, size: image.size))
                        return rep.representation(using: .png, properties: [:])
                    }
                    self.document.watchface = self.document.watchface ※ { watchface in
                        switch watchface.resources?.images {
                        case .ultraCube(let v):
                            let baseImageURL = base.map {_ in "base_" + UUID().uuidString + ".jpeg"} ?? v.imageList[row].baseImageURL // TODO?: heic
                            let backgroundImageURL: String? = back.map {_ in "back_" + UUID().uuidString + ".jpeg"} // TODO?: heic
                            let maskImageURL: String? = maskPng.map {_ in "mask_" + UUID().uuidString + ".png"}
                            watchface.resources?.files[baseImageURL] = base
                            _ = backgroundImageURL.map {watchface.resources?.files[$0] = back}
                            _ = maskImageURL.map {watchface.resources?.files[$0] = maskPng}
                            watchface.resources?.images = .ultraCube(v ※ {
                                // TODO: resize
                                $0.imageList[row].cropX = 0
                                $0.imageList[row].cropY = 0
                                $0.imageList[row].cropW = Double(new.baseImage?.size.width ?? 0)
                                $0.imageList[row].cropH = Double(new.baseImage?.size.height ?? 0)
                                $0.imageList[row].originalCropX = 0
                                $0.imageList[row].originalCropY = 0
                                $0.imageList[row].originalCropW = Double(new.baseImage?.size.width ?? 0)
                                $0.imageList[row].originalCropH = Double(new.baseImage?.size.height ?? 0)
                                $0.imageList[row].baseImageURL = baseImageURL
                                $0.imageList[row].backgroundImageURL = backgroundImageURL
                                $0.imageList[row].maskImageURL = maskImageURL
                            })
                        case .photos?, nil:
                            break
                        }
                    }
                    // TODO: apply editing
                }.store(in: &cancellables)
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

            switch watchface.resources?.images {
            case .photos(let v)?:
                let filenameBase = UUID().uuidString
                let item = Watchface.Resources.PhotosV1.Item(
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
                watchface.resources?.images = .photos(v ※ {$0.imageList.append(item)})
                watchface.resources?.files[item.imageURL] = imageData
                watchface.resources?.files[item.irisVideoURL] = movieData
            case .ultraCube(let v)?:
                let filenameBase = UUID().uuidString
                let item = Watchface.Resources.UltraCubeV2.Item(
                    baseImageURL: "\(filenameBase).jpg",
                    maskImageURL: nil,
                    backgroundImageURL: nil,
                    localIdentifier: "",
                    modificationDate: Date(),
                    cropH: 0,
                    cropW: 0,
                    cropX: 0,
                    cropY: 0,
                    originalCropH: 0,
                    originalCropW: 0,
                    originalCropX: 0,
                    originalCropY: 0,
                    baseImageZorder: 0,
                    maskedImageZorder: 1,
                    timeElementZorder: 2,
                    timeElementUnitBaseline: 0.8035714285714286,
                    timeElementUnitHeight: 0.2411167512690355,
                    imageAOTBrightness: 0.5,
                    parallaxFlat: false,
                    parallaxScale: 1.075,
                    userAdjusted: false)
                watchface.resources?.images = .ultraCube(v ※ {$0.imageList.append(item)})
                watchface.resources?.files[item.baseImageURL] = imageData
            case nil:
                break
            }
        }
        reloadDocument()
    }

    @IBAction func removeImage(_ sender: Any?) {
        guard case 0..<resourceItems.count = imageListTableView.selectedRow else { return }
        document.watchface = document.watchface ※ { watchface in
            var removedURLs: [String] = []
            switch watchface.resources?.images {
            case .photos(let v)?:
                watchface.resources?.images = .photos(v ※ {
                    let removed = $0.imageList.remove(at: imageListTableView.selectedRow)
                    removedURLs.append(contentsOf: [removed.imageURL, removed.irisVideoURL].compactMap {$0})
                })
            case .ultraCube(let v)?:
                watchface.resources?.images = .ultraCube(v ※ {
                    let removed = $0.imageList.remove(at: imageListTableView.selectedRow)
                    removedURLs.append(contentsOf: [removed.baseImageURL, removed.backgroundImageURL, removed.maskImageURL].compactMap {$0})
                })
            case nil:
                break
            }
            removedURLs.forEach {
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
        case .relativeDate(let p):
            let df = DateFormatter()
            df.dateStyle = .short
            df.timeStyle = .short
            df.doesRelativeDateFormatting = true
            return df.string(from: p.date)
        }
    }
}

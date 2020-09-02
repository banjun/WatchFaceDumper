import Cocoa
import NorthLayout
import Ikemen

final class ViewController: NSViewController {
    private let snapshot = NSImageView()
    private let snapshotLabel = NSTextField(labelWithString: "snapshot")
    private let noBordersSnapshot = NSImageView()
    private let noBordersSnapshotLabel = NSTextField(labelWithString: "no_borders_snapshot")
    private let deviceBorderSnapshot = NSImageView()
    private let deviceBorderSnapshotLabel = NSTextField(labelWithString: "device_border_snapshot")
    private let imageListStackView = NSStackView() ※ {
        $0.orientation = .horizontal
    }
    private let complicationsTopLabel = NSTextField(labelWithString: "complications.top")
    private let complicationsBottomLabel = NSTextField(labelWithString: "complications.bottom")

    override func viewDidLoad() {
        super.viewDidLoad()

        let autolayout = view.northLayoutFormat([:], [
            "snapshot": snapshot,
            "snapshotLabel": snapshotLabel,
            "noBordersSnapshot": noBordersSnapshot,
            "noBordersSnapshotLabel": noBordersSnapshotLabel,
            "deviceBorderSnapshot": deviceBorderSnapshot,
            "deviceBorderSnapshotLabel": deviceBorderSnapshotLabel,
            "imageList": imageListStackView,
            "imageListLabel": NSTextField(labelWithString: "Resources/Images"),
            "complicationsTop": complicationsTopLabel,
            "complicationsBottom": complicationsBottomLabel,
            "spacer0": MinView(),
            "spacer1": MinView(),
            "spacer2": MinView(),
        ])
        autolayout("H:|-[spacer0][snapshot][spacer1(spacer0)][noBordersSnapshot][spacer2(spacer0)][deviceBorderSnapshot]-(>=20)-|")
        autolayout("H:|-(>=20)-[snapshotLabel]-(>=20)-[noBordersSnapshotLabel]-(>=20)-[deviceBorderSnapshotLabel]-(>=20)-|")
        autolayout("H:|-[imageListLabel]-|")
        autolayout("H:|-[imageList]-|")
        autolayout("H:|-[complicationsTop]-|")
        autolayout("H:|-[complicationsBottom]-|")
        autolayout("V:|-[snapshot]-[snapshotLabel]-(>=20)-[imageListLabel]")
        autolayout("V:|-[noBordersSnapshot]-[noBordersSnapshotLabel]-(>=20)-[imageListLabel]")
        autolayout("V:|-[deviceBorderSnapshot]-[deviceBorderSnapshotLabel]-(>=20)-[imageListLabel]")
        autolayout("V:[imageListLabel]-[imageList]-[complicationsTop]-[complicationsBottom]-|")

        snapshot.centerYAnchor.constraint(equalTo: noBordersSnapshot.centerYAnchor).isActive = true
        snapshot.centerYAnchor.constraint(equalTo: deviceBorderSnapshot.centerYAnchor).isActive = true

        snapshot.centerXAnchor.constraint(equalTo: snapshotLabel.centerXAnchor).isActive = true
        noBordersSnapshot.centerXAnchor.constraint(equalTo: noBordersSnapshotLabel.centerXAnchor).isActive = true
        deviceBorderSnapshot.centerXAnchor.constraint(equalTo: deviceBorderSnapshotLabel.centerXAnchor).isActive = true
    }

    var watchface: Watchface? {
        didSet {
            NSLog("%@", "\(watchface)")
            snapshot.image = watchface.flatMap {NSImage(data: $0.snapshot)}
            noBordersSnapshot.image = watchface.flatMap {NSImage(data: $0.no_borders_snapshot)}
            deviceBorderSnapshot.image = watchface.flatMap {$0.device_border_snapshot}.flatMap {NSImage(data: $0)}

            imageListStackView.arrangedSubviews.forEach {
                imageListStackView.removeArrangedSubview($0)
                $0.removeFromSuperview()
            }

            let resources = watchface?.resources
            let images = (resources.flatMap {r in r.images.imageList.compactMap {r.files[$0.imageURL]}.compactMap {NSImage(data: $0)}} ?? [])
            images.forEach {
                imageListStackView.addArrangedSubview(NSImageView(image: $0))
            }

            complicationsTopLabel.stringValue = "complications.top: " + (watchface?.metadata.complications_names.top ?? "") + " " +  (watchface?.metadata.complication_sample_templates.top?.sampleText.map {"(\($0))"} ?? "")
            complicationsBottomLabel.stringValue = "complications.bottom: " + (watchface?.metadata.complications_names.bottom ?? "") + " " + (watchface?.metadata.complication_sample_templates.bottom?.sampleText.map {"(\($0))"} ?? "")
        }
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

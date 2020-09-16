import AppKit
import Ikemen

final class ImageItemRowView: NSTableRowView {
    private let imageView = NSImageView() ※ {
        $0.imageFrameStyle = .photo
        $0.isEditable = true
    }
    private let movieView = EditableAVPlayerView()
    var imageDidChange: ((NSImage?) -> Void)?
    var movieDidChange: ((Data?) -> Void)?

    struct ImageItem {
        var image: NSImage?
        var movie: Data?
    }

    init(item: ImageItem) {
        super.init(frame: .zero)

        let autolayout = northLayoutFormat([:], [
            "size": NSTextField(labelWithString: item.image.map {"\(Int($0.size.width))×\(Int($0.size.height))"} ?? "no image"),
            "image": imageView ※ {
                $0.target = self
                $0.action = #selector(imageViewDidChangeValue(_:))
                $0.image = item.image
                if let image = item.image {
                    $0.widthAnchor.constraint(equalTo: $0.heightAnchor, multiplier: image.size.width / image.size.height).isActive = true
                }
            },
            "movie": item.movie.map { data in
                movieView ※ {
                    $0.controlsStyle = .minimal
                    $0.data = data
                    $0.dataDidChange = { [weak self] data in
                        self?.movieDidChange?(data)
                    }
                }
            } ?? NSView(),
        ])
        autolayout("H:|-[size]|") // typically "384x480" (38mm)
        autolayout("H:|-[image]-[movie(image)]|")
        autolayout("V:|-[size]-[image(240)]-|")
        autolayout("V:|-[size]-[movie(image)]-|")
    }

    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    @IBAction func imageViewDidChangeValue(_ sender: Any?) {
        imageDidChange?(imageView.image)
    }
}

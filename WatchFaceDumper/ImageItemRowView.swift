import AppKit
import Ikemen

final class ImageItemRowView: NSTableRowView {
    private let titleLabel = NSTextField(labelWithString: "")
    private let imageView = EditableImageView()
    private var imageViewAspectConstraint: NSLayoutConstraint? {
        didSet {
            oldValue?.isActive = false
            imageViewAspectConstraint?.isActive = true
        }
    }
    private let movieView = EditableAVPlayerView()
    var imageDidChange: ((NSImage?) -> Void)?
    var movieDidChange: ((Data?) -> Void)?

    struct ImageItem {
        var image: NSImage?
        var movie: Data?
    }

    var item: ImageItem {
        didSet {
            reloadItem()
        }
    }

    init(item: ImageItem) {
        self.item = item
        super.init(frame: .zero)

        let autolayout = northLayoutFormat([:], [
            "title": titleLabel,
            "image": imageView ※ {
                $0.imageDidChange = { [weak self] in
                    self?.item.image = $0
                    self?.imageDidChange?($0)
                }
            },
            "movie": movieView ※ { movieView in
                movieView.dataDidChange = { [weak self] data in
                    self?.item.movie = data
                    self?.movieDidChange?(data)
                }
            },
        ])
        autolayout("H:|-[title]-|") // typically "384x480" (38mm)
        autolayout("H:|-[image]-[movie(image)]|")
        autolayout("V:|-[title]-[image(240)]-|")
        autolayout("V:|-[title]-[movie(image)]-|")

        reloadItem()
    }

    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    private func reloadItem() {
        titleLabel.stringValue = [
            item.image.map {"\(Int($0.size.width))×\(Int($0.size.height))"} ?? "no image",
            item.movie != nil ? "Live Photo" : "Single (not a Live Photo)"
        ].joined(separator: ", ")

        if imageView.image != item.image {
            imageView.image = item.image
        }
        imageViewAspectConstraint = item.image.map { image in
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: image.size.width / image.size.height)
        }

        if movieView.data != item.movie {
            movieView.data = item.movie
        }
        movieView.controlsStyle = item.movie != nil ? .minimal : .none
    }
}

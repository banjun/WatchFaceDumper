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
    var movieDidChange: (((data: Data, duration: Double?)?) -> Void)?

    struct ImageItem: Equatable {
        static func == (lhs: ImageItemRowView.ImageItem, rhs: ImageItemRowView.ImageItem) -> Bool {
            lhs.image?.tiffRepresentation == rhs.image?.tiffRepresentation
                && lhs.movie?.data == rhs.movie?.data
                && lhs.movie?.duration == rhs.movie?.duration
        }

        var image: NSImage?
        var movie: (data: Data, duration: Double?)?
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
                movieView.movieDidChange = { [weak self] in
                    self?.item.movie = $0.map {($0.data, $0.duration)}
                    self?.movieDidChange?(self?.item.movie)
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

        if movieView.data != item.movie?.data {
            movieView.movie = item.movie.map {.init(data: $0.data, duration: $0.duration)}
        }
        movieView.controlsStyle = item.movie != nil ? .minimal : .none
    }
}

final class UltraCubeImageItemRowView: NSTableRowView {
    private let titleLabel = NSTextField(labelWithString: "")
    private let baseImageView = EditableImageView()
    private let backImageView = EditableImageView()
    private let maskImageView = EditableImageView()

    struct ImageItem: Equatable {
        var baseImage: NSImage?
        var backImage: NSImage?
        var maskImage: NSImage?

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.baseImage?.tiffRepresentation == rhs.baseImage?.tiffRepresentation
            && lhs.backImage?.tiffRepresentation == rhs.backImage?.tiffRepresentation
            && lhs.maskImage?.tiffRepresentation == rhs.maskImage?.tiffRepresentation
        }
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
            "base": baseImageView,
            "back": backImageView,
            "mask": maskImageView])
        autolayout("H:|-[title]-|")
        autolayout("H:|-[base]-[back(base)]-[mask(base)]-|")
        autolayout("V:|-[title]-[base(240)]-|")
        autolayout("V:|-[title]-[back(base)]-|")
        autolayout("V:|-[title]-[mask(base)]-|")

        reloadItem()
    }

    required init?(coder: NSCoder) {fatalError("init(coder:) has not been implemented")}

    private func reloadItem() {
        titleLabel.stringValue = [
            item.baseImage.map {"\(Int($0.size.width))×\(Int($0.size.height))"} ?? "no image (Portrait)",
            (item.backImage != nil && item.maskImage != nil) ? "Portrait Photo" : "(Missing Portrait Support)"
        ].joined(separator: ", ")
        baseImageView.image = item.baseImage
        backImageView.image = item.backImage
        maskImageView.image = item.maskImage
    }
}

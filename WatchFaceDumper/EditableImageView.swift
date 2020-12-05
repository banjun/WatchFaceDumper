import Cocoa
import NorthLayout

struct ImageCrop {
    var cropX: Int
    var cropY: Int
    var cropW: Int
    var cropH: Int
//    var originalCropX: Int
//    var originalCropY: Int
//    var originalCropW: Int
//    var originalCropH: Int
}
extension ImageCrop {
    init(_ item: Watchface.Resources.Metadata.Item) {
        cropX = Int(item.cropX)
        cropY = Int(item.cropY)
        cropW = Int(item.cropW)
        cropH = Int(item.cropH)
//        originalCropX = Int(item.originalCropX)
//        originalCropY = Int(item.originalCropY)
//        originalCropW = Int(item.originalCropW)
//        originalCropH = Int(item.originalCropH)
    }
}

final class EditableImageView: NSView {
    private let imageView = NSImageView()
    let openButton = NSButton(title: "Open...", target: nil, action: nil)
    let cropButton = NSButton(title: "Crop...", target: nil, action: nil)
    
    var image: NSImage? {
        get {imageView.image}
        set {
            imageView.image = newValue
            updateUI()
        }
    }
    var imageCrop: ImageCrop?
    
    var imageDidChange: ((NSImage?) -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
            
        imageView.imageFrameStyle = .photo
        imageView.isEditable = true
        imageView.target = self
        imageView.action = #selector(imageViewDidChangeValue(_:))
        openButton.target = self
        openButton.action = #selector(open(_:))
        cropButton.target = self
        cropButton.action = #selector(crop(_:))
        
        let autolayout = northLayoutFormat([:], ["image": imageView, "open": openButton, "crop": cropButton])
        autolayout("H:|[image]|")
        autolayout("V:|[image]|")
        openButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        openButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        cropButton.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        cropButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        addSubview(openButton, positioned: .above, relativeTo: nil)
        addSubview(cropButton, positioned: .above, relativeTo: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layout() {
        super.layout()
        trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
    }
    
    private var trackingArea: NSTrackingArea? {
        didSet {
            if let oldValue = oldValue {
                removeTrackingArea(oldValue)
            }
            if let newValue = trackingArea {
                addTrackingArea(newValue)
            }
        }
    }
    
    private func updateUI() {
        openButton.isHidden = image != nil
        cropButton.isHidden = !(hover && image != nil)
    }
    
    @IBAction func imageViewDidChangeValue(_ sender: Any?) {
        imageDidChange?(imageView.image)
    }
    
    @IBAction func open(_ sender: Any?) {
        guard let window = window else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        if #available(OSX 11.0, *) {
            panel.allowedContentTypes = [.image]
        } else {
            panel.allowedFileTypes = ["png", "jpeg", "jpg"]
        }
        panel.beginSheetModal(for: window) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .OK:
                guard let url = panel.url, let image = NSImage(contentsOf: url) else { return }
                self.image = image
                self.imageDidChange?(image)
            case .abort:
                break
            default:
                break
            }
        }
    }
    
    private var cropViewController: ImageCropViewController?
    
    @IBAction func crop(_ sender: Any?) {
        guard let image = image else { return }
        cropViewController = ImageCropViewController(image: image, imageCrop: imageCrop ?? ImageCrop(cropX: 0, cropY: 0, cropW: 480, cropH: 384))//, originalCropX: 0, originalCropY: 0, originalCropW: Int(image.size.width), originalCropH: Int(image.size.height)))
        let popover = NSPopover()
        popover.contentViewController = cropViewController
        popover.behavior = .transient
        popover.show(relativeTo: cropButton.bounds, of: cropButton, preferredEdge: .minY)
    }
    
    private var hover: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        hover = true
    }
    
    override func mouseExited(with event: NSEvent) {
        hover = false
    }
}

import Ikemen

final class AutolayoutLabel: NSTextField {
    init() {
        super.init(frame: .zero)
        setupAutolayoutLabel()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupAutolayoutLabel()
    }
    
    private func setupAutolayoutLabel() {
        drawsBackground = false
        isBezeled = false
        isEditable = false
        maximumNumberOfLines = 0
        setContentCompressionResistancePriority(.init(rawValue: 9), for: .horizontal)
    }
}

final class ImageCropViewController: NSViewController {
    var imageCrop: ImageCrop {
        didSet {
            updateUI()
        }
    }
    var imageViewTranslate: NSAffineTransform {
        guard let image = imageView.image else { return NSAffineTransform() }
        let scale = CGFloat(imageCrop.cropW) / CGFloat(image.size.width)
        return NSAffineTransform() ※ {
            $0.scale(by: scale)
        }
    }
    
    private let cropXLabel = AutolayoutLabel()
    private let cropYLabel = AutolayoutLabel()
    private let cropWLabel = AutolayoutLabel()
    private let cropHLabel = AutolayoutLabel()
    private let imageView = TransformImageView()
    private let overlayMaskView = OverlayMaskView()
    
    init(image: NSImage, imageCrop: ImageCrop) {
        self.imageCrop = imageCrop
        super.init(nibName: nil, bundle: nil)
        self.imageView.image = image
    }
    required init?(coder: NSCoder) {fatalError()}
    
    override func loadView() {
        view = NSView(frame: .zero)
        
        let autolayout = view.northLayoutFormat([:], [
            "cropX": cropXLabel,
            "cropY": cropYLabel,
            "cropW": cropWLabel,
            "cropH": cropHLabel,
            "overlay": overlayMaskView,
            "image": imageView,
        ])
        autolayout("H:|-[cropX]-|")
        autolayout("H:|-[cropY]-|")
        autolayout("H:|-[cropW]-|")
        autolayout("H:|-[cropH]-|")
        autolayout("H:|-[overlay]-|")
        autolayout("V:|-[cropX]-[cropY]-[cropW]-[cropH]-[overlay]-|")
        if let image = imageView.image {
            imageView.widthAnchor.constraint(equalToConstant: CGFloat(image.size.width)).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: CGFloat(image.size.height)).isActive = true
        }
        imageView.centerXAnchor.constraint(equalTo: overlayMaskView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: overlayMaskView.centerYAnchor).isActive = true
        view.addSubview(imageView, positioned: .below, relativeTo: nil)
        view.addSubview(overlayMaskView, positioned: .above, relativeTo: nil)
        updateUI()
    }
    
    private func updateUI() {
        cropXLabel.stringValue = "cropX = \(imageCrop.cropX)"
        cropYLabel.stringValue = "cropY = \(imageCrop.cropY)"
        cropWLabel.stringValue = "cropW = \(imageCrop.cropW)"
        cropHLabel.stringValue = "cropH = \(imageCrop.cropH)"
        imageView.transform = imageViewTranslate
    }
    
    final class TransformImageView: NSView {
        var image: NSImage? {
            didSet {setNeedsDisplay(bounds)}
        }
        var transform: NSAffineTransform = .init() {
            didSet {setNeedsDisplay(bounds)}
        }
        
        override func draw(_ dirtyRect: NSRect) {
            guard let image = image else { return }
            NSGraphicsContext.current?.saveGraphicsState()
            defer { NSGraphicsContext.current?.restoreGraphicsState() }
            transform.concat()
            image.draw(at: .zero, from: NSRect(x: 0, y: 0, width: image.size.width, height: image.size.height), operation: .sourceOver, fraction: 1)
        }
    }
    
    final class OverlayMaskView: NSView {
        var cropSize: CGSize = .init(width: 384, height: 480)
        var padding: CGFloat = 128
        
        init() {
            super.init(frame: .zero)
            setContentCompressionResistancePriority(.required, for: .horizontal)
            setContentCompressionResistancePriority(.required, for: .vertical)
            setContentHuggingPriority(.required, for: .horizontal)
            setContentHuggingPriority(.required, for: .vertical)
        }
        required init?(coder: NSCoder) {fatalError()}
        
        override func draw(_ dirtyRect: NSRect) {
            NSColor(calibratedWhite: 1, alpha: 0.75).setFill()
            bounds.fill(using: .copy)
            bounds.insetBy(dx: padding, dy: padding).fill(using: .clear)
        }
        override var intrinsicContentSize: NSSize {
            CGSize(width: cropSize.width + padding * 2, height: cropSize.height + padding * 2)
        }
    }
}

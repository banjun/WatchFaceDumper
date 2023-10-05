import Foundation

public struct PortraitWatchface {
    public var device_size: Int = 2
    public var style: Style
    public var snapshot: Data
    public var no_borders_snapshot: Data
    public var dateComplication: Complication?
    public var bottomComplication: Complication?
    public var resources: Resources

    public init(device_size: Int = 2, style: Style, snapshot: Data, no_borders_snapshot: Data, dateComplication: Complication? = nil, bottomComplication: Complication? = nil, resources: Resources) {
        self.device_size = device_size
        self.style = style
        self.snapshot = snapshot
        self.no_borders_snapshot = no_borders_snapshot
        self.dateComplication = dateComplication
        self.bottomComplication = bottomComplication
        self.resources = resources
    }
    
    public enum Style: String {
        /// Classic
        case style1 = "style 1"
        /// Modern
        case style2 = "style 2"
        /// Rounded
        case style3 = "style 3"
    }

    public struct Resources {
        public typealias Metadata = Watchface.Resources.UltraCubeV2
        public var images: Metadata
        /// filename -> content
        public var files: [String: Data]

        public init(images: Metadata, files: [String: Data]) {
            self.images = images
            self.files = files
        }
    }

    public struct Complication {
        public var name: String
        public var template: Watchface.Metadata.ComplicationTemplate
        // TODO: eliminate nil?
        public var faceItem: Watchface.Face.Complications.Item?
        /// (filename -> content)
        public var data: [String: Data]?

        public init(name: String, template: Watchface.Metadata.ComplicationTemplate, faceItem: Watchface.Face.Complications.Item? = nil, data: [String: Data]? = nil) {
            self.name = name
            self.template = template
            self.faceItem = faceItem
            self.data = data
        }
    }
}

extension PortraitWatchface {
    public init?(watchface: Watchface) {
        guard let style = watchface.face.customization.style.flatMap(Self.Style.init),
              let resources = watchface.resources,
              let resourcesMetadata = Resources.Metadata(images: resources.images) else { return nil }
        self.init(
            device_size: watchface.metadata.device_size,
            style: style,
            snapshot: watchface.snapshot,
            no_borders_snapshot: watchface.no_borders_snapshot,
            dateComplication: watchface.metadata.complication_sample_templates.date.map {
                Complication(
                    name: watchface.metadata.complications_names.date ?? "Off",
                    template: $0,
                    faceItem: watchface.face.complications?.date,
                    data: watchface.complicationData?.date)
            },
            bottomComplication: watchface.metadata.complication_sample_templates.bottom.map {
                Complication(
                    name: watchface.metadata.complications_names.bottom ?? "Off",
                    template: $0,
                    faceItem: watchface.face.complications?.bottom,
                    data: watchface.complicationData?.bottom)
            },
            resources: .init(images: resourcesMetadata, files: resources.files))
    }
}
extension PortraitWatchface.Resources.Metadata {
    public init?(images: Watchface.Resources.Metadata) {
        guard case .ultraCube(let metadata) = images else { return nil }
        self.init(
            imageList: metadata.imageList.map {
                Item(
                    baseImageURL: $0.baseImageURL,
                    maskImageURL: $0.maskImageURL,
                    backgroundImageURL: $0.backgroundImageURL,
                    localIdentifier: $0.localIdentifier,
                    modificationDate: $0.modificationDate,
                    originalCropH: $0.originalCropH,
                    originalCropW: $0.originalCropW,
                    originalCropX: $0.originalCropX,
                    originalCropY: $0.originalCropY,
                    baseImageZorder: $0.baseImageZorder,
                    maskedImageZorder: $0.maskedImageZorder,
                    timeElementZorder: $0.timeElementZorder,
                    imageAOTBrightness: $0.imageAOTBrightness,
                    parallaxFlat: $0.parallaxFlat,
                    parallaxScale: $0.parallaxScale,
                    userAdjusted: $0.userAdjusted)
            },
            version: metadata.version)
    }
}
extension Watchface.Resources.Metadata {
    public init(images: PortraitWatchface.Resources.Metadata) {
        self = .ultraCube(.init(imageList: images.imageList, version: images.version))
    }
}

extension Watchface {
    public init(portraitWatchface portrait: PortraitWatchface) {
        self.init(
            metadata: .init(
                complication_sample_templates: .init(bottom: portrait.bottomComplication?.template, date: portrait.dateComplication?.template),
                complications_names:.init(
                    bottom: portrait.bottomComplication?.name,
                    date: portrait.dateComplication?.name),
                complications_item_ids: .init(),
                complications_bundle_ids: nil),
            face: .init(
                face_type: .bundle,
                bundle_id: .comAppleNTKUltraCubeFaceBundle,
                resource_directory: true,
                customization: .init(color: nil, content: "custom", position: nil, style: portrait.style.rawValue, typeface: nil),
                complications: .init(bottom: portrait.bottomComplication?.faceItem, date: portrait.dateComplication?.faceItem)),
            snapshot: portrait.snapshot,
            no_borders_snapshot: portrait.no_borders_snapshot,
            resources: .init(images: .init(images: portrait.resources.images), files: portrait.resources.files),
            complicationData: [portrait.bottomComplication?.data, portrait.dateComplication?.data].compactMap {$0}.isEmpty ? nil : .init(
                bottom: portrait.bottomComplication?.data, date: portrait.dateComplication?.data))
    }
}

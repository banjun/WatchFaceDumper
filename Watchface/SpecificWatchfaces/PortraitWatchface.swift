import Foundation

public struct PortraitWatchface {
    public var device_size: Int = 2
    public var style: Style
    public var snapshot: Data
    public var no_borders_snapshot: Data
    public var dateComplication: Complication?
    public var bottomComplication: Complication?
    public var resources: Resources

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
                    timeElementImageZorder: $0.timeElementImageZorder,
                    imageAOTBrightness: $0.imageAOTBrightness,
                    parallaxFlat: $0.parallaxFlat,
                    parallaxScale: $0.parallaxScale,
                    userAdjusted: $0.userAdjusted)
            },
            version: metadata.version)
    }
}

extension Watchface {
    // TODO
}

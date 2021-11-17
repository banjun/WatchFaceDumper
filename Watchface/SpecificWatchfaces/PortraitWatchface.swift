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
        public var images: Metadata
        /// filename -> content
        public var files: [String: Data]

        public struct Metadata: Codable {
            public var imageList: [Item]
            public var version: Int = 1

            public struct Item: Codable {
                /// UltraCube has some
                public var baseImageURL: String
                /// UltraCube may have some paired with backgroundImageURL
                public var maskImageURL: String?
                /// UltraCube may have some paired with maskImageURL
                public var backgroundImageURL: String?

                /// required for watchface sharing... it seems like PHAsset local identifier "UUID/L0/001". an empty string should work anyway.
                public var localIdentifier: String
                public var modificationDate: Date? = Date()

                public var originalCropH: Double
                public var originalCropW: Double
                public var originalCropX: Double
                public var originalCropY: Double

                /// UltraCube has some
                public var baseImageZorder: Int = 0
                /// UltraCube has some
                public var maskedImageZorder: Int = 1
                /// UltraCube has some
                public var timeElementImageZorder: Int = 2
                /// UltraCube has some. 0-1?
                public var imageAOTBrightness: Double = 0.5
                /// UltraCube has some. constant false?
                public var parallaxFlat: Bool = false
                /// UltraCube has some. constant 1.075?
                public var parallaxScale: Double = 1.075
                /// UltraCube has some
                public var userAdjusted: Bool = false
            }

            public init(imageList: [Item], version: Int = 1) {
                self.imageList = imageList
                self.version = version
            }
        }

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
        let imageList = images.imageList.compactMap { item -> Item? in
            guard let baseImageURL = item.baseImageURL,
                  let baseImageZorder = item.baseImageZorder,
                  let maskedImageZorder = item.maskedImageZorder,
                  let timeElementImageZorder = item.timeElementImageZorder,
                  let imageAOTBrightness = item.imageAOTBrightness,
                  let parallaxFlat = item.parallaxFlat,
                  let parallaxScale = item.parallaxScale,
                  let userAdjusted = item.userAdjusted else { return nil }
            return Item(
                baseImageURL: baseImageURL,
                maskImageURL: item.maskImageURL,
                backgroundImageURL: item.backgroundImageURL,
                localIdentifier: item.localIdentifier,
                modificationDate: item.modificationDate,
                originalCropH: item.originalCropH,
                originalCropW: item.originalCropW,
                originalCropX: item.originalCropX,
                originalCropY: item.originalCropY,
                baseImageZorder: baseImageZorder,
                maskedImageZorder: maskedImageZorder,
                timeElementImageZorder: timeElementImageZorder,
                imageAOTBrightness: imageAOTBrightness,
                parallaxFlat: parallaxFlat,
                parallaxScale: parallaxScale,
                userAdjusted: userAdjusted)
        }
        guard imageList.count == images.imageList.count else { return nil }
        self.init(
            imageList: imageList,
            version: images.version)
    }
}

extension Watchface {
    
}

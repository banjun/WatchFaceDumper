import Foundation

extension Watchface.Metadata {
    public enum ComplicationTemplate: Codable {
        case utilitarianSmallFlat(CLKComplicationTemplateUtilitarianSmallFlat)
        case utilitarianLargeFlat(CLKComplicationTemplateUtilitarianLargeFlat)
        case circularSmallSimpleText(CLKComplicationTemplateCircularSmallSimpleText)
        case circularSmallSimpleImage(CLKComplicationTemplateCircularSmallSimpleImage)
        case graphicCornerGaugeText(CLKComplicationTemplateGraphicCornerGaugeText)
        case graphicCornerTextImage(CLKComplicationTemplateGraphicCornerTextImage)
        case graphicBezelCircularText(CLKComplicationTemplateGraphicBezelCircularText)
        case graphicCircularImage(CLKComplicationTemplateGraphicCircularImage)
        case graphicCircularOpenGaugeSimpleText(CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText)

        public init(from decoder: Decoder) throws {
            let anyTemplate = try CLKComplicationTemplateAny(from: decoder)
            switch anyTemplate.class {
            case "CLKComplicationTemplateUtilitarianSmallFlat": self = .utilitarianSmallFlat(try .init(from: decoder))
            case "CLKComplicationTemplateUtilitarianLargeFlat": self = .utilitarianLargeFlat(try .init(from: decoder))
            case "CLKComplicationTemplateCircularSmallSimpleText": self = .circularSmallSimpleText(try .init(from: decoder))
            case "CLKComplicationTemplateCircularSmallSimpleImage": self = .circularSmallSimpleImage(try .init(from: decoder))
            case "CLKComplicationTemplateGraphicCornerGaugeText": self = .graphicCornerGaugeText(try .init(from: decoder))
            case "CLKComplicationTemplateGraphicCornerTextImage": self = .graphicCornerTextImage(try .init(from: decoder))
            case "CLKComplicationTemplateGraphicBezelCircularText": self = .graphicBezelCircularText(try .init(from: decoder))
            case "CLKComplicationTemplateGraphicCircularImage": self = .graphicCircularImage(try .init(from: decoder))
            case "CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText": self = .graphicCircularOpenGaugeSimpleText(try .init(from: decoder))
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown ComplicationTemplate type: \(anyTemplate.class)"))
            }
        }

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .utilitarianSmallFlat(let t): try t.encode(to: encoder)
            case .utilitarianLargeFlat(let t): try t.encode(to: encoder)
            case .circularSmallSimpleText(let t): try t.encode(to: encoder)
            case .circularSmallSimpleImage(let t): try t.encode(to: encoder)
            case .graphicCornerGaugeText(let t): try t.encode(to: encoder)
            case .graphicCornerTextImage(let t): try t.encode(to: encoder)
            case .graphicBezelCircularText(let t): try t.encode(to: encoder)
            case .graphicCircularImage(let t): try t.encode(to: encoder)
            case .graphicCircularOpenGaugeSimpleText(let t): try t.encode(to: encoder)
            }
        }

        private struct CLKComplicationTemplateAny: Codable {
            var `class`: String

            init(`class`: String) {
                self.class = `class`
            }
        }
    }

    public struct CLKComplicationTemplateUtilitarianSmallFlat: Codable {
        public var `class`: String = "CLKComplicationTemplateUtilitarianSmallFlat"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider = .date(.init())

        public init(`class`: String = "CLKComplicationTemplateUtilitarianSmallFlat", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, textProvider: CLKTextProvider = .date(.init())) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.textProvider = textProvider
        }
    }

    public struct CLKComplicationTemplateUtilitarianLargeFlat: Codable {
        public var `class`: String = "CLKComplicationTemplateUtilitarianLargeFlat"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider = .date(.init())
        public var imageProvider: ImageProvider?

        public init(`class`: String = "CLKComplicationTemplateUtilitarianLargeFlat", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, textProvider: CLKTextProvider = .date(.init()), imageProvider: ImageProvider? = nil) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.textProvider = textProvider
            self.imageProvider = imageProvider
        }
    }

    public struct CLKComplicationTemplateCircularSmallSimpleText: Codable {
        public var `class`: String = "CLKComplicationTemplateCircularSmallSimpleText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider = .date(.init())
        public var tintColor: Color

        public init(`class`: String = "CLKComplicationTemplateCircularSmallSimpleText", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, textProvider: CLKTextProvider = .date(.init()), tintColor: Color) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.textProvider = textProvider
            self.tintColor = tintColor
        }
    }

    public struct CLKComplicationTemplateCircularSmallSimpleImage: Codable {
        public var `class`: String = "CLKComplicationTemplateCircularSmallSimpleImage"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var imageProvider: ImageProvider
        public var tintColor: Color

        public init(`class`: String = "CLKComplicationTemplateCircularSmallSimpleImage", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, imageProvider: ImageProvider, tintColor: Color) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.imageProvider = imageProvider
            self.tintColor = tintColor
        }
    }

    public struct CLKComplicationTemplateGraphicCornerGaugeText: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCornerGaugeText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var leadingTextProvider: CLKTextProvider
        public var outerTextProvider: CLKTextProvider
        public var gaugeProvider: CLKSimpleGaugeProvider

        public init(`class`: String = "CLKComplicationTemplateGraphicCornerGaugeText", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, leadingTextProvider: CLKTextProvider, outerTextProvider: CLKTextProvider, gaugeProvider: CLKSimpleGaugeProvider) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.leadingTextProvider = leadingTextProvider
            self.outerTextProvider = outerTextProvider
            self.gaugeProvider = gaugeProvider
        }
    }

    public struct CLKComplicationTemplateGraphicCornerTextImage: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCornerTextImage"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider
        public var imageProvider: ImageProvider
        public var tintColor: Color?

        public init(`class`: String = "CLKComplicationTemplateGraphicCornerTextImage", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, textProvider: CLKTextProvider, imageProvider: ImageProvider, tintColor: Color? = nil) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.textProvider = textProvider
            self.imageProvider = imageProvider
            self.tintColor = tintColor
        }
    }

    public struct CLKComplicationTemplateGraphicBezelCircularText: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicBezelCircularText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider
        public var BezelCircularClassName: String = "CLKComplicationTemplateGraphicCircularMetadata"
        public var circularTemplate: CircularTemplate
        public struct CircularTemplate: Codable {
            public var `class`: String = "CLKComplicationTemplateGraphicCircularMetadata"
            public var version: Int = 30000
            public var metadata: Metadata
            public var creationDate: Double = Date().timeIntervalSince1970
            public struct Metadata: Codable {
                public init() {}
            }

            public init(`class`: String = "CLKComplicationTemplateGraphicCircularMetadata", version: Int = 30000, metadata: Metadata, creationDate: Double = Date().timeIntervalSince1970) {
                self.class = `class`
                self.version = version
                self.metadata = metadata
                self.creationDate = creationDate
            }
        }

        public init(`class`: String = "CLKComplicationTemplateGraphicBezelCircularText", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, textProvider: CLKTextProvider, BezelCircularClassName: String = "CLKComplicationTemplateGraphicCircularMetadata", circularTemplate: CircularTemplate) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.textProvider = textProvider
            self.BezelCircularClassName = BezelCircularClassName
            self.circularTemplate = circularTemplate
        }
    }

    public struct CLKComplicationTemplateGraphicCircularImage: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCircularImage"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var imageProvider: ImageProvider

        public init(`class`: String = "CLKComplicationTemplateGraphicCircularImage", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, imageProvider: ImageProvider) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.imageProvider = imageProvider
        }
    }

    public struct CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var centerTextProvider: CLKTextProvider
        public var bottomTextProvider: CLKTextProvider
        public var gaugeProvider: CLKSimpleGaugeProvider

        public init(`class`: String = "CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText", version: Int = 30000, creationDate: Double = Date().timeIntervalSince1970, centerTextProvider: CLKTextProvider, bottomTextProvider: CLKTextProvider, gaugeProvider: CLKSimpleGaugeProvider) {
            self.class = `class`
            self.version = version
            self.creationDate = creationDate
            self.centerTextProvider = centerTextProvider
            self.bottomTextProvider = bottomTextProvider
            self.gaugeProvider = gaugeProvider
        }
    }
}

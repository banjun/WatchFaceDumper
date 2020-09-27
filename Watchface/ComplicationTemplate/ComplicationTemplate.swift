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
        }
    }

    public struct CLKComplicationTemplateUtilitarianSmallFlat: Codable {
        public var `class`: String = "CLKComplicationTemplateUtilitarianSmallFlat"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider = .date(.init())
    }

    public struct CLKComplicationTemplateUtilitarianLargeFlat: Codable {
        public var `class`: String = "CLKComplicationTemplateUtilitarianLargeFlat"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider = .date(.init())
        public var imageProvider: ImageProvider?
    }

    public struct CLKComplicationTemplateCircularSmallSimpleText: Codable {
        public var `class`: String = "CLKComplicationTemplateCircularSmallSimpleText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider = .date(.init())
        public var tintColor: Color
    }

    public struct CLKComplicationTemplateCircularSmallSimpleImage: Codable {
        public var `class`: String = "CLKComplicationTemplateCircularSmallSimpleImage"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var imageProvider: ImageProvider
        public var tintColor: Color
    }

    public struct CLKComplicationTemplateGraphicCornerGaugeText: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCornerGaugeText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var leadingTextProvider: CLKTextProvider
        public var outerTextProvider: CLKTextProvider
        public var gaugeProvider: CLKSimpleGaugeProvider
    }

    public struct CLKComplicationTemplateGraphicCornerTextImage: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCornerTextImage"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var textProvider: CLKTextProvider
        public var imageProvider: ImageProvider
        public var tintColor: Color?
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
            public struct Metadata: Codable {}
        }
    }

    public struct CLKComplicationTemplateGraphicCircularImage: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCircularImage"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var imageProvider: ImageProvider
    }

    public struct CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText: Codable {
        public var `class`: String = "CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText"
        public var version: Int = 30000
        public var creationDate: Double = Date().timeIntervalSince1970
        public var centerTextProvider: CLKTextProvider
        public var bottomTextProvider: CLKTextProvider
        public var gaugeProvider: CLKSimpleGaugeProvider
    }
}

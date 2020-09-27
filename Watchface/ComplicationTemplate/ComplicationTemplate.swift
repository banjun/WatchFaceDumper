import Foundation

extension Watchface.Metadata {
    enum ComplicationTemplate: Codable {
        case utilitarianSmallFlat(CLKComplicationTemplateUtilitarianSmallFlat)
        case utilitarianLargeFlat(CLKComplicationTemplateUtilitarianLargeFlat)
        case circularSmallSimpleText(CLKComplicationTemplateCircularSmallSimpleText)
        case circularSmallSimpleImage(CLKComplicationTemplateCircularSmallSimpleImage)
        case graphicCornerGaugeText(CLKComplicationTemplateGraphicCornerGaugeText)
        case graphicCornerTextImage(CLKComplicationTemplateGraphicCornerTextImage)
        case graphicBezelCircularText(CLKComplicationTemplateGraphicBezelCircularText)
        case graphicCircularImage(CLKComplicationTemplateGraphicCircularImage)
        case graphicCircularOpenGaugeSimpleText(CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText)

        init(from decoder: Decoder) throws {
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

        func encode(to encoder: Encoder) throws {
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

    struct CLKComplicationTemplateUtilitarianSmallFlat: Codable {
        var `class`: String = "CLKComplicationTemplateUtilitarianSmallFlat"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var textProvider: CLKTextProvider = .date(.init())
    }

    struct CLKComplicationTemplateUtilitarianLargeFlat: Codable {
        var `class`: String = "CLKComplicationTemplateUtilitarianLargeFlat"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var textProvider: CLKTextProvider = .date(.init())
        var imageProvider: ImageProvider?
    }

    struct CLKComplicationTemplateCircularSmallSimpleText: Codable {
        var `class`: String = "CLKComplicationTemplateCircularSmallSimpleText"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var textProvider: CLKTextProvider = .date(.init())
        var tintColor: Color
    }

    struct CLKComplicationTemplateCircularSmallSimpleImage: Codable {
        var `class`: String = "CLKComplicationTemplateCircularSmallSimpleImage"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var imageProvider: ImageProvider
        var tintColor: Color
    }

    struct CLKComplicationTemplateGraphicCornerGaugeText: Codable {
        var `class`: String = "CLKComplicationTemplateGraphicCornerGaugeText"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var leadingTextProvider: CLKTextProvider
        var outerTextProvider: CLKTextProvider
        var gaugeProvider: CLKSimpleGaugeProvider
    }

    struct CLKComplicationTemplateGraphicCornerTextImage: Codable {
        var `class`: String = "CLKComplicationTemplateGraphicCornerTextImage"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var textProvider: CLKTextProvider
        var imageProvider: ImageProvider
        var tintColor: Color?
    }

    struct CLKComplicationTemplateGraphicBezelCircularText: Codable {
        var `class`: String = "CLKComplicationTemplateGraphicBezelCircularText"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var textProvider: CLKTextProvider
        var BezelCircularClassName: String = "CLKComplicationTemplateGraphicCircularMetadata"
        var circularTemplate: CircularTemplate
        struct CircularTemplate: Codable {
            var `class`: String = "CLKComplicationTemplateGraphicCircularMetadata"
            var version: Int = 30000
            var metadata: Metadata
            var creationDate: Double = Date().timeIntervalSince1970
            struct Metadata: Codable {}
        }
    }

    struct CLKComplicationTemplateGraphicCircularImage: Codable {
        var `class`: String = "CLKComplicationTemplateGraphicCircularImage"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var imageProvider: ImageProvider
    }

    struct CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText: Codable {
        var `class`: String = "CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText"
        var version: Int = 30000
        var creationDate: Double = Date().timeIntervalSince1970
        var centerTextProvider: CLKTextProvider
        var bottomTextProvider: CLKTextProvider
        var gaugeProvider: CLKSimpleGaugeProvider
    }
}

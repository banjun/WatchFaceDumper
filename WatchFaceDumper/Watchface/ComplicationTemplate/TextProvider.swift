import Foundation

extension Watchface.Metadata {
    enum CLKTextProvider: Codable {
        case date(CLKDateTextProvider)
        case time(CLKTimeTextProvider)
        case compound(CLKCompoundTextProvider)
        case simple(CLKSimpleTextProvider)

        init(from decoder: Decoder) throws {
            let anyProvider = try CLKTextProviderAny(from: decoder)
            switch anyProvider.class {
            case "CLKDateTextProvider": self = .date(try .init(from: decoder))
            case "CLKTimeTextProvider": self = .time(try .init(from: decoder))
            case "CLKCompoundTextProvider": self = .compound(try .init(from: decoder))
            case "CLKSimpleTextProvider": self = .simple(try .init(from: decoder))
            default:
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown CLKTextProvider type: \(anyProvider.class)"))
            }
        }

        func encode(to encoder: Encoder) throws {
            switch self {
            case .date(let p): try p.encode(to: encoder)
            case .time(let p): try p.encode(to: encoder)
            case .compound(let p): try p.encode(to: encoder)
            case .simple(let p): try p.encode(to: encoder)
            }
        }

        private struct CLKTextProviderAny: Codable {
            var `class`: String
        }
    }

    struct CLKDateTextProvider: Codable {
        var `class`: String = "CLKDateTextProvider"
        var date: Date = .init()
        var _uppercase: Bool = true
        var calendarUnits: Int = 528
    }

    struct CLKTimeTextProvider: Codable {
        var `class`: String = "CLKTimeTextProvider"
        var date: Date = .init()
        var timeZone: String = "US/Pacific"
    }

    struct CLKSimpleTextProvider: Codable {
        var `class`: String = "CLKSimpleTextProvider"
        var text: String = "サンフランシスコ"
        var tintColor: Color?
    }

    struct CLKCompoundTextProvider: Codable {
        var `class`: String = "CLKCompoundTextProvider"
        var textProviders: [CLKTextProvider] = [.time(.init()), .simple(.init())]
        var format_segments: [String] = ["", " ", ""]

        private enum CodingKeys: String, CodingKey {
            case `class`
            case textProviders
            case format_segments = "format segments"
        }
    }
}

import Foundation

extension Watchface.Metadata {
    public enum CLKTextProvider: Codable {
        case date(CLKDateTextProvider)
        case time(CLKTimeTextProvider)
        case compound(CLKCompoundTextProvider)
        case simple(CLKSimpleTextProvider)

        public init(from decoder: Decoder) throws {
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

        public func encode(to encoder: Encoder) throws {
            switch self {
            case .date(let p): try p.encode(to: encoder)
            case .time(let p): try p.encode(to: encoder)
            case .compound(let p): try p.encode(to: encoder)
            case .simple(let p): try p.encode(to: encoder)
            }
        }

        private struct CLKTextProviderAny: Codable {
            var `class`: String

            init(`class`: String) {
                self.class = `class`
            }
        }
    }

    public struct CLKDateTextProvider: Codable {
        public var `class`: String = "CLKDateTextProvider"
        public var date: Date = .init()
        public var _uppercase: Bool = true
        public var calendarUnits: Int = 528

        public init(`class`: String = "CLKDateTextProvider", date: Date = .init(), _uppercase: Bool = true, calendarUnits: Int = 528) {
            self.class = `class`
            self.date = date
            self._uppercase = _uppercase
            self.calendarUnits = calendarUnits
        }
    }

    public struct CLKTimeTextProvider: Codable {
        public var `class`: String = "CLKTimeTextProvider"
        public var date: Date = .init()
        public var timeZone: String = "US/Pacific"

        public init(`class`: String = "CLKTimeTextProvider", date: Date = .init(), timeZone: String = "US/Pacific") {
            self.class = `class`
            self.date = date
            self.timeZone = timeZone
        }
    }

    public struct CLKSimpleTextProvider: Codable {
        public var `class`: String = "CLKSimpleTextProvider"
        public var text: String = "サンフランシスコ"
        public var tintColor: Color?

        public init(`class`: String = "CLKSimpleTextProvider", text: String = "サンフランシスコ", tintColor: Color? = nil) {
            self.class = `class`
            self.text = text
            self.tintColor = tintColor
        }
    }

    public struct CLKCompoundTextProvider: Codable {
        public var `class`: String = "CLKCompoundTextProvider"
        public var textProviders: [CLKTextProvider] = [.time(.init()), .simple(.init())]
        public var format_segments: [String] = ["", " ", ""]

        private enum CodingKeys: String, CodingKey {
            case `class`
            case textProviders
            case format_segments = "format segments"
        }

        public init(`class`: String = "CLKCompoundTextProvider", textProviders: [CLKTextProvider] = [.time(.init()), .simple(.init())], format_segments: [String] = ["", " ", ""]) {
            self.class = `class`
            self.textProviders = textProviders
            self.format_segments = format_segments
        }
    }
}

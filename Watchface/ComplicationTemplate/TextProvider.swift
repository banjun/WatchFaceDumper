import Foundation

extension Watchface.Metadata {
    public enum CLKTextProvider: Codable {
        case date(CLKDateTextProvider)
        case time(CLKTimeTextProvider)
        case compound(CLKCompoundTextProvider)
        case simple(CLKSimpleTextProvider)
        case relativeDate(CLKRelativeDateTextProvider)

        public init(from decoder: Decoder) throws {
            let anyProvider = try CLKTextProviderAny(from: decoder)
            switch anyProvider.class {
            case CLKDateTextProvider.class: self = .date(try .init(from: decoder))
            case CLKTimeTextProvider.class: self = .time(try .init(from: decoder))
            case CLKCompoundTextProvider.class: self = .compound(try .init(from: decoder))
            case CLKSimpleTextProvider.class: self = .simple(try .init(from: decoder))
            case CLKRelativeDateTextProvider.class: self = .relativeDate(try .init(from: decoder))
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
            case .relativeDate(let p): try p.encode(to: encoder)
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
        public static let `class`: String = "CLKDateTextProvider"
        public var `class`: String = Self.class
        public var date: Date = .init()
        public var _uppercase: Bool = true
        public var calendarUnits: Int = 528

        public init(`class`: String = Self.class, date: Date = .init(), _uppercase: Bool = true, calendarUnits: Int = 528) {
            self.class = `class`
            self.date = date
            self._uppercase = _uppercase
            self.calendarUnits = calendarUnits
        }
    }

    public struct CLKTimeTextProvider: Codable {
        public static let `class`: String = "CLKTimeTextProvider"
        public var `class`: String = Self.class
        public var date: Date = .init()
        public var timeZone: String = "US/Pacific"

        public init(`class`: String = Self.class, date: Date = .init(), timeZone: String = "US/Pacific") {
            self.class = `class`
            self.date = date
            self.timeZone = timeZone
        }
    }

    public struct CLKSimpleTextProvider: Codable {
        public static let `class`: String = "CLKSimpleTextProvider"
        public var `class`: String = Self.class
        public var text: String = "サンフランシスコ"
        public var tintColor: Color?

        public init(`class`: String = Self.class, text: String = "サンフランシスコ", tintColor: Color? = nil) {
            self.class = `class`
            self.text = text
            self.tintColor = tintColor
        }
    }

    public struct CLKCompoundTextProvider: Codable {
        public static let `class` = "CLKCompoundTextProvider"
        public var `class`: String = Self.class
        public var textProviders: [CLKTextProvider] = [.time(.init()), .simple(.init())]
        public var format_segments: [String] = ["", " ", ""]

        private enum CodingKeys: String, CodingKey {
            case `class`
            case textProviders
            case format_segments = "format segments"
        }

        public init(`class`: String = Self.class, textProviders: [CLKTextProvider] = [.time(.init()), .simple(.init())], format_segments: [String] = ["", " ", ""]) {
            self.class = `class`
            self.textProviders = textProviders
            self.format_segments = format_segments
        }
    }
    
    public struct CLKRelativeDateTextProvider: Codable {
        public static let `class` = "CLKRelativeDateTextProvider"
        public var `class`: String = Self.class
        public var calendarUnits: UInt // CFCalendarUnit [.day, .hour, .minute]
        public var relativeDateStyle: Int
        public var date: Date
        
        public init(`class`: String = Self.class, calendarUnits: UInt = ([.day, .hour, .minute] as CFCalendarUnit).rawValue, relativeDateStyle: Int = 0, date: Date = .init()) {
            self.class = `class`
            self.calendarUnits = calendarUnits
            self.relativeDateStyle = relativeDateStyle
            self.date = date
        }
    }
}

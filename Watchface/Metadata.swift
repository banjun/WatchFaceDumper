import Foundation

extension Watchface {
    struct Metadata: Codable {
        var version: Int = 2
        var device_size = 2 // 38mm, 42mm?
        var complication_sample_templates: ComplicationPositionDictionary<ComplicationTemplate>
        var complications_names: ComplicationPositionDictionary<String>
        var complications_item_ids: ComplicationPositionDictionary<Int>
        var complications_bundle_ids: ComplicationPositionDictionary<String>? // com.apple.weather.watchapp, com.apple.HeartRate, com.apple.NanoCalendar

        struct ComplicationPositionDictionary<Value: Codable>: Codable {
            var top: Value?
            var bottom: Value?
            var top_left: Value?
            var top_right: Value?
            var bottom_left: Value?
            var bottom_center: Value?
            var bottom_right: Value?
            var slot1: Value?
            var slot2: Value?
            var slot3: Value?
            var bezel: Value?

            enum CodingKeys: String, CodingKey, CaseIterable {
                case top, bottom
                case top_left = "top-left"
                case top_right = "top-right"
                case bottom_left = "bottom-left"
                case bottom_center = "bottom-center"
                case bottom_right = "bottom-right"
                case slot1, slot2, slot3
                case bezel
            }

            subscript(_ key: CodingKeys) -> Value? {
                get {
                    switch key {
                    case .top: return top
                    case .bottom: return bottom
                    case .top_left: return top_left
                    case .top_right: return top_right
                    case .bottom_left: return bottom_left
                    case .bottom_center: return bottom_center
                    case .bottom_right: return bottom_right
                    case .slot1: return slot1
                    case .slot2: return slot2
                    case .slot3: return slot3
                    case .bezel: return bezel
                    }
                }
                set {
                    switch key {
                    case .top: top = newValue
                    case .bottom: bottom = newValue
                    case .top_left: top_left = newValue
                    case .top_right: top_right = newValue
                    case .bottom_left: bottom_left = newValue
                    case .bottom_center: bottom_center = newValue
                    case .bottom_right: bottom_right = newValue
                    case .slot1: slot1 = newValue
                    case .slot2: slot2 = newValue
                    case .slot3: slot3 = newValue
                    case .bezel: bezel = newValue
                    }
                }
            }
        }

        struct Color: Codable {
            var red: Double
            var green: Double
            var blue: Double
            var alpha: Double
        }
    }
}

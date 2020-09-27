import Foundation

extension Watchface {
    struct Face: Codable {
        var version: Int = 4
        var face_type: FaceType
        var resource_directory: Bool? = true // infograph: nil
        var customization: Customization
        var complications: Complications?

        private enum CodingKeys: String, CodingKey {
            case version
            case customization
            case complications
            case face_type = "face type"
            case resource_directory = "resource directory"
        }

        enum FaceType: String, Codable {
            case photos // has [top, bottom]
            case kaleidoscope // has [top-left, top-right, bottom-center]
            case whistler_analog = "whistler-analog" // aka infograph
        }

        struct Customization: Codable {
            var color: String? // photo: "none"
            var content: String? // photo: "custom", kaleidoscope: "asset custom", infograph: nil
            var position: String? // "top"
            var style: String? // kaleidoscope: "radial"
        }

        struct Complications: Codable {
            var top: Item?
            var bottom: Item?
            var top_left: Item?
            var top_right: Item?
            var bottom_left: Item?
            var bottom_center: Item?
            var bottom_right: Item?
            var slot_1: Item?
            var slot_2: Item?
            var slot_3: Item?
            var bezel: Item?

            private enum CodingKeys: String, CodingKey {
                case top, bottom
                case top_left = "top left"
                case top_right = "top right"
                case bottom_left = "bottom left"
                case bottom_center = "bottom center"
                case bottom_right = "bottom right"
                case slot_1 = "slot 1"
                case slot_2 = "slot 2"
                case slot_3 = "slot 3"
                case bezel
            }

            struct Item: Codable {
                var app: String // "date", "weather", "heartrate", "com.apple.shortcuts.watch"
                var `extension`: String? // "com.apple.shortcuts.watch"
                var complication_descriptor: ComplicationDescriptor?

                private enum CodingKeys: String, CodingKey {
                    case app, `extension`
                    case complication_descriptor = "complication descriptor"
                }

                struct ComplicationDescriptor: Codable {
                    var displayName: String
                    var supportedFamilies: [Int] // [0, 1, ..., 12]
                    var identifier: String // UUID
                    var userActivity: String? // Base64 encoded NSKeyedArchiver archived UAUserActivityInfo
                }
            }
        }
    }
}

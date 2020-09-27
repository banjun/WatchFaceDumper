import Foundation

extension Watchface {
    public struct Face: Codable {
        public var version: Int = 4
        public var face_type: FaceType
        public var resource_directory: Bool? = true // infograph: nil
        public var customization: Customization
        public var complications: Complications?

        private enum CodingKeys: String, CodingKey {
            case version
            case customization
            case complications
            case face_type = "face type"
            case resource_directory = "resource directory"
        }

        public enum FaceType: String, Codable {
            case photos // has [top, bottom]
            case kaleidoscope // has [top-left, top-right, bottom-center]
            case whistler_analog = "whistler-analog" // aka infograph
        }

        public struct Customization: Codable {
            public var color: String? // photo: "none"
            public var content: String? // photo: "custom", kaleidoscope: "asset custom", infograph: nil
            public var position: String? // "top"
            public var style: String? // kaleidoscope: "radial"
        }

        public struct Complications: Codable {
            public var top: Item?
            public var bottom: Item?
            public var top_left: Item?
            public var top_right: Item?
            public var bottom_left: Item?
            public var bottom_center: Item?
            public var bottom_right: Item?
            public var slot_1: Item?
            public var slot_2: Item?
            public var slot_3: Item?
            public var bezel: Item?

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

            public struct Item: Codable {
                public var app: String // "date", "weather", "heartrate", "com.apple.shortcuts.watch"
                public var `extension`: String? // "com.apple.shortcuts.watch"
                public var complication_descriptor: ComplicationDescriptor?

                private enum CodingKeys: String, CodingKey {
                    case app, `extension`
                    case complication_descriptor = "complication descriptor"
                }

                public struct ComplicationDescriptor: Codable {
                    public var displayName: String
                    public var supportedFamilies: [Int] // [0, 1, ..., 12]
                    public var identifier: String // UUID
                    public var userActivity: String? // Base64 encoded NSKeyedArchiver archived UAUserActivityInfo
                }
            }
        }
    }
}

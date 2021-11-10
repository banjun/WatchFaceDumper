import Foundation

extension Watchface {
    public struct Face: Codable {
        public var version: Int = 4
        public var face_type: FaceType
        /// non-nil when face type = bundle
        public var bundle_id: BundleID?
        /// infograph: nil
        public var resource_directory: Bool? = true
        public var customization: Customization
        public var complications: Complications?
        /// unknown values
        public var argon: Argon?

        private enum CodingKeys: String, CodingKey {
            case version
            case customization
            case complications
            case face_type = "face type"
            case bundle_id = "bundle id"
            case resource_directory = "resource directory"
        }

        public enum FaceType: String, Codable {
            /// has [top, bottom]
            case photos
            /// has [top-left, top-right, bottom-center]
            case kaleidoscope
            /// aka infograph
            case whistler_analog = "whistler-analog"
            /// portrait (has bundle id)
            case bundle
        }

        public enum BundleID: String, Codable {
            case comAppleNTKUltraCubeFaceBundle = "com.apple.NTKUltraCubeFaceBundle"
        }

        public struct Customization: Codable {
            /// photo: "none"
            public var color: String?
            /// photo: "custom", kaleidoscope: "asset custom", infograph: nil
            public var content: String?
            /// "top"
            public var position: String?
            /// kaleidoscope: "radial"
            public var style: String?

            public init(color: String? = nil, content: String? = nil, position: String? = nil, style: String? = nil) {
                self.color = color
                self.content = content
                self.position = position
                self.style = style
            }
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
                /// "date", "weather", "heartrate", "com.apple.shortcuts.watch"
                public var app: String
                /// "com.apple.shortcuts.watch"
                public var `extension`: String?
                public var complication_descriptor: ComplicationDescriptor?

                private enum CodingKeys: String, CodingKey {
                    case app, `extension`
                    case complication_descriptor = "complication descriptor"
                }

                public struct ComplicationDescriptor: Codable {
                    public var displayName: String
                    /// [0, 1, ..., 12]
                    public var supportedFamilies: [Int]
                    /// UUID
                    public var identifier: String
                    /// Base64 encoded NSKeyedArchiver archived UAUserActivityInfo
                    public var userActivity: String?

                    public init(displayName: String, supportedFamilies: [Int], identifier: String, userActivity: String? = nil) {
                        self.displayName = displayName
                        self.supportedFamilies = supportedFamilies
                        self.identifier = identifier
                        self.userActivity = userActivity
                    }
                }

                public init(app: String, `extension`: String? = nil, complication_descriptor: ComplicationDescriptor? = nil) {
                    self.app = app
                    self.extension = `extension`
                    self.complication_descriptor = complication_descriptor
                }
            }

            public init(top: Item? = nil, bottom: Item? = nil, top_left: Item? = nil, top_right: Item? = nil, bottom_left: Item? = nil, bottom_center: Item? = nil, bottom_right: Item? = nil, slot_1: Item? = nil, slot_2: Item? = nil, slot_3: Item? = nil, bezel: Item? = nil) {
                self.top = top
                self.bottom = bottom
                self.top_left = top_left
                self.top_right = top_right
                self.bottom_left = bottom_left
                self.bottom_center = bottom_center
                self.bottom_right = bottom_right
                self.slot_1 = slot_1
                self.slot_2 = slot_2
                self.slot_3 = slot_3
                self.bezel = bezel
            }
        }

        public struct Argon {
            /// unknown base64. (possibly constant value)
            public var k: String?
            /// unknown {hash}.aea. (possibly constant value)
            public var n: String?

            public init(k: String? = nil, n: String? = nil) {
                self.k = k
                self.n = n
            }
        }

        public init(version: Int = 4, face_type: FaceType, bundle_id: BundleID? = nil, resource_directory: Bool? = true, customization: Customization, complications: Complications? = nil, argon: Argon? = nil) {
            self.version = version
            self.face_type = face_type
            self.bundle_id = bundle_id
            self.resource_directory = resource_directory
            self.customization = customization
            self.complications = complications
            self.argon = argon
        }
    }
}

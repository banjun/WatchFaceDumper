import Foundation

extension Watchface {
    public struct Resources {
        public var images: Metadata
        /// filename -> content
        public var files: [String: Data]

        public struct Metadata: Codable {
            public var imageList: [Item]
            public var version: Int = 1

            public struct Item: Codable {
                public struct Analysis: Codable {
                    public var bgBrightness: Double
                    public var bgHue: Double
                    public var bgSaturation: Double
                    public var coloredText: Bool
                    public var complexBackground: Bool
                    public var shadowBrightness: Double
                    public var shadowHue: Double
                    public var shadowSaturation: Double
                    public var textBrightness: Double
                    public var textHue: Double
                    public var textSaturation: Double
                    public var version: Int = 1

                    public init(bgBrightness: Double, bgHue: Double, bgSaturation: Double, coloredText: Bool, complexBackground: Bool, shadowBrightness: Double, shadowHue: Double, shadowSaturation: Double, textBrightness: Double, textHue: Double, textSaturation: Double, version: Int = 1) {
                        self.bgBrightness = bgBrightness
                        self.bgHue = bgHue
                        self.bgSaturation = bgSaturation
                        self.coloredText = coloredText
                        self.complexBackground = complexBackground
                        self.shadowBrightness = shadowBrightness
                        self.shadowHue = shadowHue
                        self.shadowSaturation = shadowSaturation
                        self.textBrightness = textBrightness
                        self.textHue = textHue
                        self.textSaturation = textSaturation
                        self.version = version
                    }
                }

                /// photos has some, kaleidoscope has none
                public var topAnalysis: Analysis?
                /// photos has some, kaleidoscope has none
                public var leftAnalysis: Analysis?
                /// photos has some, kaleidoscope has none
                public var bottomAnalysis: Analysis?
                /// photos has some, kaleidoscope has none
                public var rightAnalysis: Analysis?

                /// photos has some, UltraCube has none
                public var imageURL: String?
                /// photos has none, UltraCube has some
                public var baseImageURL: String?
                /// photos has none, UltraCube may have some paired with backgroundImageURL
                public var maskImageURL: String?
                /// photos has none, UltraCube may have some paired with maskImageURL
                public var backgroundImageURL: String?

                /// photos has some
                public var irisDuration: Double? = 3
                /// photos has some
                public var irisStillDisplayTime: Double? = 0
                /// photos has some
                public var irisVideoURL: String?
                /// photos has some
                public var isIris: Bool? = true

                /// required for watchface sharing... it seems like PHAsset local identifier "UUID/L0/001". an empty string should work anyway.
                public var localIdentifier: String
                public var modificationDate: Date? = Date()

                public var cropH: Double = 480
                public var cropW: Double = 384
                public var cropX: Double = 0
                public var cropY: Double = 0
                public var originalCropH: Double
                public var originalCropW: Double
                public var originalCropX: Double
                public var originalCropY: Double

                /// UltraCube has some
                public var baseImageZorder: Int? = 0
                /// UltraCube has some
                public var maskedImageZorder: Int? = 1
                /// UltraCube has some
                public var timeElementImageZorder: Int? = 2
                /// UltraCube has some. 0-1?
                public var imageAOTBrightness: Double? = 0.5
                /// UltraCube has some. constant false?
                public var parallaxFlat: Bool? = false
                /// UltraCube has some. constant 1.075?
                public var parallaxScale: Double? = 1.075
                /// UltraCube has some
                public var userAdjusted: Bool? = false

            }

            public init(imageList: [Item], version: Int = 1) {
                self.imageList = imageList
                self.version = version
            }
        }

        public init(images: Metadata, files: [String: Data]) {
            self.images = images
            self.files = files
        }
    }
}

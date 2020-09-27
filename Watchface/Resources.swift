import Foundation

extension Watchface {
    public struct Resources {
        public var images: Metadata
        public var files: [String: Data] // filename -> content

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
                }

                public var topAnalysis: Analysis? // photos has some, kaleidoscope has none
                public var leftAnalysis: Analysis? // photos has some, kaleidoscope has none
                public var bottomAnalysis: Analysis? // photos has some, kaleidoscope has none
                public var rightAnalysis: Analysis? // photos has some, kaleidoscope has none

                public var imageURL: String

                public var irisDuration: Double = 3
                public var irisStillDisplayTime: Double = 0
                public var irisVideoURL: String
                public var isIris: Bool = true

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
            }
        }
    }
}

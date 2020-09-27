import Foundation

extension Watchface {
    struct Resources {
        var images: Metadata
        var files: [String: Data] // filename -> content

        struct Metadata: Codable {
            var imageList: [Item]
            var version: Int = 1

            struct Item: Codable {
                struct Analysis: Codable {
                    var bgBrightness: Double
                    var bgHue: Double
                    var bgSaturation: Double
                    var coloredText: Bool
                    var complexBackground: Bool
                    var shadowBrightness: Double
                    var shadowHue: Double
                    var shadowSaturation: Double
                    var textBrightness: Double
                    var textHue: Double
                    var textSaturation: Double
                    var version: Int = 1
                }

                var topAnalysis: Analysis? // photos has some, kaleidoscope has none
                var leftAnalysis: Analysis? // photos has some, kaleidoscope has none
                var bottomAnalysis: Analysis? // photos has some, kaleidoscope has none
                var rightAnalysis: Analysis? // photos has some, kaleidoscope has none

                var imageURL: String

                var irisDuration: Double = 3
                var irisStillDisplayTime: Double = 0
                var irisVideoURL: String
                var isIris: Bool = true

                /// required for watchface sharing... it seems like PHAsset local identifier "UUID/L0/001". an empty string should work anyway.
                var localIdentifier: String
                var modificationDate: Date? = Date()

                var cropH: Double = 480
                var cropW: Double = 384
                var cropX: Double = 0
                var cropY: Double = 0
                var originalCropH: Double
                var originalCropW: Double
                var originalCropX: Double
                var originalCropY: Double
            }
        }
    }
}

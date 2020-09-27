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

                public init(topAnalysis: Analysis? = nil, leftAnalysis: Analysis? = nil, bottomAnalysis: Analysis? = nil, rightAnalysis: Analysis? = nil, imageURL: String, irisDuration: Double = 3, irisStillDisplayTime: Double = 0, irisVideoURL: String, isIris: Bool = true, localIdentifier: String, modificationDate: Date? = Date(), cropH: Double = 480, cropW: Double = 384, cropX: Double = 0, cropY: Double = 0, originalCropH: Double, originalCropW: Double, originalCropX: Double, originalCropY: Double) {
                    self.topAnalysis = topAnalysis
                    self.leftAnalysis = leftAnalysis
                    self.bottomAnalysis = bottomAnalysis
                    self.rightAnalysis = rightAnalysis
                    self.imageURL = imageURL
                    self.irisDuration = irisDuration
                    self.irisStillDisplayTime = irisStillDisplayTime
                    self.irisVideoURL = irisVideoURL
                    self.isIris = isIris
                    self.localIdentifier = localIdentifier
                    self.modificationDate = modificationDate
                    self.cropH = cropH
                    self.cropW = cropW
                    self.cropX = cropX
                    self.cropY = cropY
                    self.originalCropH = originalCropH
                    self.originalCropW = originalCropW
                    self.originalCropX = originalCropX
                    self.originalCropY = originalCropY
                }
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

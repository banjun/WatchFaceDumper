import Foundation

extension Watchface {
    public struct Resources {
        public var images: Metadata
        /// filename -> content
        public var files: [String: Data]
        
        public init(images: Metadata, files: [String : Data]) {
            self.images = images
            self.files = files
        }
        
        public enum Metadata: Codable {
            /// photos or kaleidoscope (can be separated into cases...)
            case photos(PhotosV1)
            /// UltraCube aka Portrait
            case ultraCube(UltraCubeV2)
            
            public init(from decoder: Decoder) throws {
                self = try (try? PhotosV1(from: decoder)).map(Self.photos)
                ?? (try? UltraCubeV2(from: decoder)).map(Self.ultraCube)
                // generate an exception as photos
                ?? Self.photos(PhotosV1(from: decoder))
            }
            
            public func encode(to encoder: Encoder) throws {
                switch self {
                case .photos(let v): try v.encode(to: encoder)
                case .ultraCube(let v): try v.encode(to: encoder)
                }
            }
        }
        
        public struct PhotosV1: Codable {
            public var imageList: [Item]
            public var version: Int = 1
            
            public init(imageList: [Item] = [], version: Int = 1) {
                self.imageList = imageList
                self.version = version
            }
            
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
                
                
                public init(topAnalysis: Analysis? = nil, leftAnalysis: Analysis? = nil, bottomAnalysis: Analysis? = nil, rightAnalysis: Analysis? = nil, imageURL: String, irisDuration: Double, irisStillDisplayTime: Double, irisVideoURL: String, isIris: Bool, localIdentifier: String, modificationDate: Date? = Date(), cropH: Double = 480, cropW: Double = 384, cropX: Double = 0, cropY: Double = 0, originalCropH: Double, originalCropW: Double, originalCropX: Double, originalCropY: Double) {
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
        }
        
        public struct UltraCubeV2: Codable {
            public var imageList: [Item]
            public var version: Int = 2
            
            public init(imageList: [Item] = [], version: Int = 2) {
                self.imageList = imageList
                self.version = version
            }
            
            public struct Item: Codable {
                public var baseImageURL: String
                /// paired with backgroundImageURL. nil for some photos
                public var maskImageURL: String?
                /// paired with maskImageURL. nil for some photos
                public var backgroundImageURL: String?
                
                /// required for watchface sharing... it seems like PHAsset local identifier "UUID/L0/001". an empty string should work anyway.
                public var localIdentifier: String
                public var modificationDate: Date? = Date()
                
                public var cropH: Double? = 480
                public var cropW: Double? = 384
                public var cropX: Double? = 0
                public var cropY: Double? = 0
                public var originalCropH: Double
                public var originalCropW: Double
                public var originalCropX: Double
                public var originalCropY: Double
                
                public var baseImageZorder: Int = 0
                public var maskedImageZorder: Int = 1
                public var timeElementZorder: Int = 2
                public var timeElementUnitBaseline: Double = 0.8035714285714286
                public var timeElementUnitHeight: Double = 0.2411167512690355
                /// 0-1?
                public var imageAOTBrightness: Double = 0.5
                /// constant false?
                public var parallaxFlat: Bool = false
                /// constant 1.075?
                public var parallaxScale: Double = 1.075
                public var userAdjusted: Bool? = false
                
                public init(
                    baseImageURL: String,
                    maskImageURL: String? = nil,
                    backgroundImageURL: String? = nil,
                    localIdentifier: String,
                    modificationDate: Date? = nil,
                    cropH: Double? = 480,
                    cropW: Double? = 384,
                    cropX: Double? = nil,
                    cropY: Double? = nil,
                    originalCropH: Double,
                    originalCropW: Double,
                    originalCropX: Double,
                    originalCropY: Double,
                    baseImageZorder: Int = 0,
                    maskedImageZorder: Int = 1,
                    timeElementZorder: Int = 2,
                    timeElementUnitBaseline: Double = 0.8035714285714286,
                    timeElementUnitHeight: Double = 0.2411167512690355,
                    imageAOTBrightness: Double = 0.5,
                    parallaxFlat: Bool = false,
                    parallaxScale: Double = 1.075,
                    userAdjusted: Bool? = nil
                ) {
                    self.baseImageURL = baseImageURL
                    self.maskImageURL = maskImageURL
                    self.backgroundImageURL = backgroundImageURL
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
                    self.baseImageZorder = baseImageZorder
                    self.maskedImageZorder = maskedImageZorder
                    self.timeElementZorder = timeElementZorder
                    self.timeElementUnitBaseline = timeElementUnitBaseline
                    self.timeElementUnitHeight = timeElementUnitHeight
                    self.imageAOTBrightness = imageAOTBrightness
                    self.parallaxFlat = parallaxFlat
                    self.parallaxScale = parallaxScale
                    self.userAdjusted = userAdjusted
                }
            }
        }
    }
}

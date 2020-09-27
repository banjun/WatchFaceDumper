import Foundation
import MirrorDiffKit

struct Watchface {
    var metadata: Metadata
    struct Metadata: Codable {
        var version: Int = 2
        var device_size = 2 // 38mm, 42mm?

        var complication_sample_templates: ComplicationPositionDictionary<ComplicationTemplate>

        enum ComplicationTemplate: Codable {
            case utilitarianSmallFlat(CLKComplicationTemplateUtilitarianSmallFlat)
            case utilitarianLargeFlat(CLKComplicationTemplateUtilitarianLargeFlat)
            case circularSmallSimpleText(CLKComplicationTemplateCircularSmallSimpleText)
            case circularSmallSimpleImage(CLKComplicationTemplateCircularSmallSimpleImage)

            init(from decoder: Decoder) throws {
                if let t = ((try? CLKComplicationTemplateUtilitarianSmallFlat(from: decoder))
                                .flatMap {$0.class == "CLKComplicationTemplateUtilitarianSmallFlat" ? $0 : nil}) {
                    self = .utilitarianSmallFlat(t)
                    return
                }
                if let t = ((try? CLKComplicationTemplateUtilitarianLargeFlat(from: decoder))
                                .flatMap {$0.class == "CLKComplicationTemplateUtilitarianLargeFlat" ? $0 : nil}) {
                    self = .utilitarianLargeFlat(t)
                    return
                }
                if let t = ((try? CLKComplicationTemplateCircularSmallSimpleText(from: decoder))
                                .flatMap {$0.class == "CLKComplicationTemplateCircularSmallSimpleText" ? $0 : nil}) {
                    self = .circularSmallSimpleText(t)
                    return
                }
                if let t = ((try? CLKComplicationTemplateCircularSmallSimpleImage(from: decoder))
                                .flatMap {$0.class == "CLKComplicationTemplateCircularSmallSimpleImage" ? $0 : nil}) {
                    self = .circularSmallSimpleImage(t)
                    return
                }


                let anyTemplate = try? CLKComplicationTemplateAny(from: decoder)
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown ComplicationTemplate type: \(anyTemplate?.class ?? "(unknown structure)")"))
            }

            func encode(to encoder: Encoder) throws {
                switch self {
                case .utilitarianSmallFlat(let t): try t.encode(to: encoder)
                case .utilitarianLargeFlat(let t): try t.encode(to: encoder)
                case .circularSmallSimpleText(let t): try t.encode(to: encoder)
                case .circularSmallSimpleImage(let t): try t.encode(to: encoder)
                }
            }

            private struct CLKComplicationTemplateAny: Codable {
                var `class`: String
            }
        }

        enum CLKTextProvider: Codable {
            case date(CLKDateTextProvider)
            case time(CLKTimeTextProvider)
            case compound(CLKCompoundTextProvider)
            case simple(CLKSimpleTextProvider)

            init(from decoder: Decoder) throws {
                if let p = ((try? CLKDateTextProvider(from: decoder))
                                .flatMap {$0.class == "CLKDateTextProvider" ? $0 : nil}) {
                    self = .date(p)
                    return
                }
                if let p = ((try? CLKTimeTextProvider(from: decoder))
                                .flatMap {$0.class == "CLKTimeTextProvider" ? $0 : nil}) {
                    self = .time(p)
                    return
                }
                if let p = ((try? CLKCompoundTextProvider(from: decoder))
                                .flatMap {$0.class == "CLKCompoundTextProvider" ? $0 : nil}) {
                    self = .compound(p)
                    return
                }
                if let p = ((try? CLKSimpleTextProvider(from: decoder))
                                .flatMap {$0.class == "CLKSimpleTextProvider" ? $0 : nil}) {
                    self = .simple(p)
                    return
                }
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown CLKTextProvider type"))
            }

            func encode(to encoder: Encoder) throws {
                switch self {
                case .date(let p): try p.encode(to: encoder)
                case .time(let p): try p.encode(to: encoder)
                case .compound(let p): try p.encode(to: encoder)
                case .simple(let p): try p.encode(to: encoder)
                }
            }
        }

        struct CLKDateTextProvider: Codable {
            var `class`: String = "CLKDateTextProvider"
            var date: Date = .init()
            var _uppercase: Bool = true
            var calendarUnits: Int = 528
        }

        struct CLKTimeTextProvider: Codable {
            var `class`: String = "CLKTimeTextProvider"
            var date: Date = .init()
            var timeZone: String = "US/Pacific"
        }

        struct CLKSimpleTextProvider: Codable {
            var `class`: String = "CLKSimpleTextProvider"
            var text: String = "サンフランシスコ"
        }

        struct CLKCompoundTextProvider: Codable {
            var `class`: String = "CLKCompoundTextProvider"
            var textProviders: [CLKTextProvider] = [.time(.init()), .simple(.init())]
            var format_segments: [String] = ["", " ", ""]

            private enum CodingKeys: String, CodingKey {
                case `class`
                case textProviders
                case format_segments = "format segments"
            }
        }

        struct CLKComplicationTemplateUtilitarianSmallFlat: Codable {
            var `class`: String = "CLKComplicationTemplateUtilitarianSmallFlat"
            var version: Int = 30000
            var creationDate: Double = Date().timeIntervalSince1970
            var textProvider: CLKTextProvider = .date(.init())
        }

        struct CLKComplicationTemplateUtilitarianLargeFlat: Codable {
            var `class`: String = "CLKComplicationTemplateUtilitarianLargeFlat"
            var version: Int = 30000
            var creationDate: Double = Date().timeIntervalSince1970
            var textProvider: CLKTextProvider = .date(.init())
            var imageProvider: ImageProvider?
        }

        struct CLKComplicationTemplateCircularSmallSimpleText: Codable {
            var `class`: String = "CLKComplicationTemplateCircularSmallSimpleText"
            var version: Int = 30000
            var creationDate: Double = Date().timeIntervalSince1970
            var textProvider: CLKTextProvider = .date(.init())
            var tintColor: TintColor
        }

        struct CLKComplicationTemplateCircularSmallSimpleImage: Codable {
            var `class`: String = "CLKComplicationTemplateCircularSmallSimpleImage"
            var version: Int = 30000
            var creationDate: Double = Date().timeIntervalSince1970
            var imageProvider: ImageProvider
            var tintColor: TintColor
        }

        struct ImageProvider: Codable {
            var onePieceImage: Item
            var twoPieceImageBackground: Item?
            var twoPieceImageForeground: Item?

            struct Item: Codable {
                var file_name: String // "13CF2F31-40CD-4F66-8C55-72A03A46DDC3.png" where .watchface/complicationData/top-right/
                var scale: Int // 3
                var renderingMode: Int // 0

                private enum CodingKeys: String, CodingKey {
                    case file_name = "file name"
                    case scale, renderingMode
                }
            }
        }

        struct TintColor: Codable {
            var red: Double
            var green: Double
            var blue: Double
            var alpha: Double
        }

        var complications_names: ComplicationPositionDictionary<String>
        var complications_item_ids: ComplicationPositionDictionary<Int>
        var complications_bundle_ids: ComplicationPositionDictionary<String>? // com.apple.weather.watchapp, com.apple.HeartRate, com.apple.NanoCalendar
    }

    var face: Face
    struct Face: Codable {
        var version: Int = 4

        var face_type: FaceType
        enum FaceType: String, Codable {
            case photos // has [top, bottom]
            case kaleidoscope // has [top-left, top-right, bottom-center]
        }
        var resource_directory: Bool = true

        var customization: Customization
        struct Customization: Codable {
            var color: String? // photo: "none"
            var content: String // photo: "custom", kaleidoscope: "asset custom"
            var position: String? // "top"
            var style: String? // kaleidoscope: "radial"
        }

        var complications: Complications?
        struct Complications: Codable {
            var top: Item?
            var bottom: Item?
            var top_left: Item?
            var top_right: Item?
            var bottom_center: Item?

            private enum CodingKeys: String, CodingKey {
                case top, bottom
                case top_left = "top left"
                case top_right = "top right"
                case bottom_center = "bottom center"
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
                    var userActivity: String // Base64 encoded NSKeyedArchiver archived UAUserActivityInfo
                }
            }
        }

        private enum CodingKeys: String, CodingKey {
            case version
            case customization
            case complications
            case face_type = "face type"
            case resource_directory = "resource directory"
        }
    }

    var snapshot: Data
    var no_borders_snapshot: Data
//    var device_border_snapshot: Data?

    var resources: Resources
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

    typealias ComplicationData = ComplicationPositionDictionary<[String: Data]> // position -> (filename -> content)
    var complicationData: ComplicationData? = nil

    struct ComplicationPositionDictionary<Value: Codable>: Codable {
        var top: Value?
        var bottom: Value?
        var top_left: Value?
        var top_right: Value?
        var bottom_center: Value?

        enum CodingKeys: String, CodingKey, CaseIterable {
            case top, bottom
            case top_left = "top-left"
            case top_right = "top-right"
            case bottom_center = "bottom-center"
        }

        subscript(_ key: CodingKeys) -> Value? {
            get {
                switch key {
                case .top: return top
                case .bottom: return bottom
                case .top_left: return top_left
                case .top_right: return top_right
                case .bottom_center: return bottom_center
                }
            }
            set {
                switch key {
                case .top: top = newValue
                case .bottom: bottom = newValue
                case .top_left: top_left = newValue
                case .top_right: top_right = newValue
                case .bottom_center: bottom_center = newValue
                }
            }
        }
    }
}

extension Watchface {
    init(fileWrapper: FileWrapper) throws {
        guard let metadata_json = fileWrapper.fileWrappers?["metadata.json"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "metadata.json not found"))
        }
        let metadata = try JSONDecoder().decode(Watchface.Metadata.self, from: metadata_json)

        guard let face_json = fileWrapper.fileWrappers?["face.json"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "face.json not found"))
        }
        let face = try JSONDecoder().decode(Watchface.Face.self, from: face_json)

        guard let snapshot = fileWrapper.fileWrappers?["snapshot.png"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "snapshot.png not found"))
        }

        guard let no_borders_snapshot = fileWrapper.fileWrappers?["no_borders_snapshot.png"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "no_borders_snapshot.png not found"))
        }

//        let device_border_snapshot = fileWrapper.fileWrappers?["device_border_snapshot.png"]?.regularFileContents

        guard let resources = fileWrapper.fileWrappers?["Resources"]?.fileWrappers else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Resources/ not found"))
        }

        guard let resources_metadata_plist = resources["Images.plist"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Images.plist not found"))
        }
        let resources_metadata = try PropertyListDecoder().decode(Watchface.Resources.Metadata.self, from: resources_metadata_plist)

        let complicationData = fileWrapper.fileWrappers?["complicationData"]

        self.init(
            metadata: metadata,
            face: face,
            snapshot: snapshot,
            no_borders_snapshot: no_borders_snapshot,
//            device_border_snapshot: device_border_snapshot,
            resources: Watchface.Resources(images: resources_metadata, files: resources_metadata.imageList.flatMap {[$0.imageURL, $0.irisVideoURL]}.reduce(into: [:]) {$0[$1] = resources[$1]?.regularFileContents}), // TODO: .pathfinders for kaleidoscope
            complicationData: complicationData.flatMap {Watchface.ComplicationData(fileWrapper: $0)}
        )
    }

    /// check a lossy reading
    func isEqualToFileWrapper(anotherFileWrapper right: FileWrapper) -> Bool {
        guard let left = try? FileWrapper(watchface: self) else { return false }
        guard left.isDirectory == right.isDirectory else { return false }

        func isEqualJSONFiles(left: FileWrapper, right: FileWrapper, filename: String) -> Bool {
            let l = left.fileWrappers?[filename]?.regularFileContents.flatMap {try? JSONSerialization.jsonObject(with: $0, options: []) as? NSDictionary}
            let r = right.fileWrappers?[filename]?.regularFileContents.flatMap {try? JSONSerialization.jsonObject(with: $0, options: []) as? NSDictionary}
            if l != r {
                NSLog("%@", "detect differences in \(filename):")
                print(diff(between: l.debugDescription, and: r.debugDescription))
            }
            return l == r
        }
        func isEqualPropertyListFiles(left: FileWrapper, right: FileWrapper, filename: String) -> Bool {
            let l = left.fileWrappers?[filename]?.regularFileContents.flatMap {try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil) as? NSDictionary}
            let r = right.fileWrappers?[filename]?.regularFileContents.flatMap {try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil) as? NSDictionary}
            if l != r {
                NSLog("%@", "detect differences in \(filename):")
                print(diff(between: l.debugDescription, and: r.debugDescription))
            }
            return l == r
        }
        func isEqualDataFiles(left: FileWrapper, right: FileWrapper, filename: String) -> Bool {
            let l = left.fileWrappers?[filename]?.regularFileContents
            let r = right.fileWrappers?[filename]?.regularFileContents
            if l != r {
                NSLog("%@", "detect differences in \(filename):")
                print(diff(between: l.debugDescription, and: r.debugDescription))
            }
            return l == r
        }

        guard left.fileWrappers?.count == right.fileWrappers?.count else { return false }
        guard isEqualJSONFiles(left: left, right: right, filename: "face.json") else { return false }
        guard isEqualJSONFiles(left: left, right: right, filename: "metadata.json") else { return false }
        guard isEqualDataFiles(left: left, right: right, filename: "snapshot.png") else { return false }
        guard isEqualDataFiles(left: left, right: right, filename: "no_borders_snapshot.png") else { return false }

        guard let leftResources = left.fileWrappers?["Resources"],
              let rightResources = right.fileWrappers?["Resources"] else { return false }
        guard leftResources.fileWrappers?.count == rightResources.fileWrappers?.count else { return false }
        guard isEqualPropertyListFiles(left: leftResources, right: rightResources, filename: "Images.plist") else { return false }
        for (filename, _) in resources.files {
            guard isEqualDataFiles(left: leftResources, right: rightResources, filename: filename) else { return false }
        }

        return true
    }
}

extension Watchface.ComplicationData {
    init?(fileWrapper: FileWrapper) {
        guard let positions = fileWrapper.fileWrappers else { return nil }
        self.init()
        CodingKeys.allCases.forEach {
            self[$0] = positions[$0.rawValue]?.fileWrappers?.compactMapValues {$0.regularFileContents}
        }
    }
}

extension FileWrapper {
    convenience init(watchface: Watchface) throws {
        self.init(directoryWithFileWrappers: [
            "face.json": FileWrapper(regularFileWithContents: try JSONEncoder().encode(watchface.face)),
            "metadata.json": FileWrapper(regularFileWithContents: try JSONEncoder().encode(watchface.metadata)),
            "snapshot.png": FileWrapper(regularFileWithContents: watchface.snapshot),
            "no_borders_snapshot.png": FileWrapper(regularFileWithContents: watchface.no_borders_snapshot),
            //            "device_border_snapshot.png": watchface.device_border_snapshot.map {FileWrapper(regularFileWithContents: $0)},
            "Resources": try FileWrapper(resources: watchface.resources),
            "complicationData": watchface.complicationData.map {FileWrapper(complicationData: $0)},
        ].compactMapValues {$0})
    }

    convenience init(resources: Watchface.Resources) throws {
        self.init(directoryWithFileWrappers: resources.files.mapValues {FileWrapper(regularFileWithContents: $0)}.merging(
                    ["Images.plist": FileWrapper(regularFileWithContents: try PropertyListEncoder().encode(resources.images))], uniquingKeysWith: {a,b in a}))
    }

    convenience init(complicationData: Watchface.ComplicationData) {
        self.init(
            directoryWithFileWrappers: Dictionary(
                uniqueKeysWithValues: Watchface.ComplicationData.CodingKeys.allCases.map {
                    ($0.rawValue, complicationData[$0].map {$0.mapValues {FileWrapper(regularFileWithContents: $0)}})
                })
                .compactMapValues {$0}
                .mapValues {FileWrapper(directoryWithFileWrappers: $0)})
    }
}

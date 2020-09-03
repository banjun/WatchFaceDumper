import Foundation

struct Watchface {
    var metadata: Metadata
    struct Metadata: Codable {
        var version: Int = 2
        var device_size = 2 // 38mm, 42mm?

        var complication_sample_templates: ComplicationSampleTemplate
        struct ComplicationSampleTemplate: Codable {
            var top: ComplicationTemplate?
            var bottom: ComplicationTemplate?

            enum ComplicationTemplate: Codable {
                case utilitarianSmallFlat(CLKComplicationTemplateUtilitarianSmallFlat)
                case utilitarianLargeFlat(CLKComplicationTemplateUtilitarianLargeFlat)

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
                    throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "unknown ComplicationTemplate type"))
                }

                func encode(to encoder: Encoder) throws {
                    switch self {
                    case .utilitarianSmallFlat(let t): try t.encode(to: encoder)
                    case .utilitarianLargeFlat(let t): try t.encode(to: encoder)
                    }
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
                var creationDate: Date = .init()
                var textProvider: CLKTextProvider = .date(.init())
            }

            struct CLKComplicationTemplateUtilitarianLargeFlat: Codable {
                var `class`: String = "CLKComplicationTemplateUtilitarianSmallFlat"
                var version: Int = 30000
                var creationDate: Date = .init()
                var textProvider: CLKTextProvider = .date(.init())

            }
        }

        var complications_names: ComplicationsNames
        struct ComplicationsNames: Codable {
            var top: String = "Off"
            var bottom: String = "Off"
        }

        var complications_item_ids: ComplicationsItemIDs
        struct ComplicationsItemIDs: Codable {
        }
    }

    var face: Face
    struct Face: Codable {
        var version: Int = 4
        var customization: Customization
        struct Customization: Codable {
            var color: String = "none"
            var content: String = "custom"
            var position: String = "top"
        }

        var face_type: String = "photos"
        var resource_directory: Bool = true

        var complications: Complications?
        struct Complications: Codable {
            var top: Item? = Item()
            struct Item: Codable {
                var app: String = "date"
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
    var device_border_snapshot: Data?

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

                var topAnalysis: Analysis
                var leftAnalysis: Analysis
                var bottomAnalysis: Analysis
                var rightAnalysis: Analysis

                var imageURL: String

                var irisDuration: Double = 3
                var irisStillDisplayTime: Double = 0
                var irisVideoURL: String
                var isIris: Bool = true

                /// required for watchface sharing... it seems like PHAsset local identifier "UUID/L0/001". an empty string should work anyway.
                var localIdentifier: String
                var modificationDate: Date = .init()

                var cropH: Int = 480
                var cropW: Int = 384
                var cropX: Int = 0
                var cropY: Int = 0
                var originalCropH: Double
                var originalCropW: Double
                var originalCropX: Double
                var originalCropY: Double
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

        let device_border_snapshot = fileWrapper.fileWrappers?["device_border_snapshot.png"]?.regularFileContents

        guard let resources = fileWrapper.fileWrappers?["Resources"]?.fileWrappers else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Resources/ not found"))
        }

        guard let resources_metadata_plist = resources["Images.plist"]?.regularFileContents else {
            throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Images.plist not found"))
        }
        let resources_metadata = try PropertyListDecoder().decode(Watchface.Resources.Metadata.self, from: resources_metadata_plist)

        self.init(
            metadata: metadata,
            face: face,
            snapshot: snapshot,
            no_borders_snapshot: no_borders_snapshot,
            device_border_snapshot: device_border_snapshot,
            resources: Watchface.Resources(images: resources_metadata, files: resources_metadata.imageList.map {$0.imageURL}.reduce(into: [:]) {$0[$1] = resources[$1]?.regularFileContents})
        )
    }
}

extension FileWrapper {
    convenience init(watchface: Watchface) throws {
        self.init(directoryWithFileWrappers: [
            "face.json": FileWrapper(regularFileWithContents: try JSONEncoder().encode(watchface.face)),
            "metadata.json": FileWrapper(regularFileWithContents: try JSONEncoder().encode(watchface.metadata)),
            "snapshot.png": FileWrapper(regularFileWithContents: watchface.snapshot),
            "no_borders_snapshot.png": FileWrapper(regularFileWithContents: watchface.no_borders_snapshot),
            "device_border_snapshot.png": watchface.device_border_snapshot.map {FileWrapper(regularFileWithContents: $0)},
            "Resources": FileWrapper(
                directoryWithFileWrappers:
                    watchface.resources.files.mapValues {FileWrapper(regularFileWithContents: $0)}.merging(
                        ["Images.plist": FileWrapper(regularFileWithContents: try PropertyListEncoder().encode(watchface.resources.images))], uniquingKeysWith: {a,b in a})),
        ].compactMapValues {$0})
    }
}

import Foundation

/// convenience shorthand struct for `Watchface` whose `face type` is `photos`
public struct PhotosWatchface {
    public var device_size: Int = 2
    public var position: Position
    public var snapshot: Data
    public var no_borders_snapshot: Data
    public var topComplication: Complication?
    public var bottomComplication: Complication?
    // TODO: simplify optionals for analysises
    public var resources: Watchface.Resources

    public struct Complication {
        public var name: String
        public var template: Watchface.Metadata.ComplicationTemplate
        // TODO: eliminate nil?
        public var faceItem: Watchface.Face.Complications.Item?
        /// (filename -> content)
        public var data: [String: Data]?

        public init(name: String, template: Watchface.Metadata.ComplicationTemplate, faceItem: Watchface.Face.Complications.Item? = nil, data: [String: Data]? = nil) {
            self.name = name
            self.template = template
            self.faceItem = faceItem
            self.data = data
        }
    }

    public enum Position: String {
        case top, bottom
    }

    public init(device_size: Int = 2, position: Position, snapshot: Data, no_borders_snapshot: Data, topComplication: Complication? = nil, bottomComplication: Complication? = nil, resources: Watchface.Resources) {
        self.device_size = device_size
        self.position = position
        self.snapshot = snapshot
        self.no_borders_snapshot = no_borders_snapshot
        self.topComplication = topComplication
        self.bottomComplication = bottomComplication
        self.resources = resources
    }
}

extension PhotosWatchface {
    public init?(watchface: Watchface) {
        guard let position = Position(rawValue: watchface.face.customization.position ?? ""),
              let resources = watchface.resources else { return nil }
        self.init(
            device_size: watchface.metadata.device_size,
            position: position,
            snapshot: watchface.snapshot,
            no_borders_snapshot: watchface.no_borders_snapshot,
            topComplication: watchface.metadata.complication_sample_templates.top.map {
                Complication(name: watchface.metadata.complications_names.top ?? "Off",
                             template: $0,
                             faceItem: watchface.face.complications?.top,
                             data: watchface.complicationData?.top)},
            bottomComplication: watchface.metadata.complication_sample_templates.bottom.map {
                Complication(name: watchface.metadata.complications_names.bottom ?? "Off",
                             template: $0,
                             faceItem: watchface.face.complications?.bottom,
                             data: watchface.complicationData?.bottom)},
            resources: resources)
    }
}

extension Watchface {
    public init(photosWatchface photos: PhotosWatchface) {
        self.init(
            metadata: .init(
                complication_sample_templates: .init(
                    top: photos.topComplication?.template,
                    bottom: photos.bottomComplication?.template),
                complications_names:.init(
                    top: photos.topComplication?.name,
                    bottom: photos.bottomComplication?.name),
                complications_item_ids: .init(),
                complications_bundle_ids: nil),
            face: .init(
                face_type: .photos,
                resource_directory: true,
                customization: .init(color: "none", content: "custom", position: photos.position.rawValue),
                complications: .init(top: photos.topComplication?.faceItem, bottom: photos.bottomComplication?.faceItem)),
            snapshot: photos.snapshot,
            no_borders_snapshot: photos.no_borders_snapshot,
            resources: photos.resources,
            complicationData: [photos.topComplication?.data, photos.bottomComplication?.data].compactMap {$0}.isEmpty ? nil : .init(
                top: photos.topComplication?.data, bottom: photos.bottomComplication?.data))
    }
}

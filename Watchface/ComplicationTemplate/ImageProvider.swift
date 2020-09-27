import Foundation

extension Watchface.Metadata {
    public struct ImageProvider: Codable {
        public var onePieceImage: Item?
        public var twoPieceImageBackground: Item?
        public var twoPieceImageForeground: Item?
        public var fullColorImage: Item?
        public var tintedImageProvider: ChildImageProvider?
        public var monochromeFilterType: Int? // 0
        public var applyScalingAndCircularMask: Bool? // true
        public var prefersFilterOverTransition: Bool? // false

        public struct Item: Codable {
            public var file_name: String // "13CF2F31-40CD-4F66-8C55-72A03A46DDC3.png" where .watchface/complicationData/top-right/
            public var scale: Int // 3
            public var renderingMode: Int // 0

            private enum CodingKeys: String, CodingKey {
                case file_name = "file name"
                case scale, renderingMode
            }
        }

        public struct ChildImageProvider: Codable {
            public var onePieceImage: Item?
        }
    }
}

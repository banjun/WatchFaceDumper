import Foundation

extension Watchface.Metadata {
    struct ImageProvider: Codable {
        var onePieceImage: Item?
        var twoPieceImageBackground: Item?
        var twoPieceImageForeground: Item?
        var fullColorImage: Item?
        var tintedImageProvider: ChildImageProvider?
        var monochromeFilterType: Int? // 0
        var applyScalingAndCircularMask: Bool? // true
        var prefersFilterOverTransition: Bool? // false

        struct Item: Codable {
            var file_name: String // "13CF2F31-40CD-4F66-8C55-72A03A46DDC3.png" where .watchface/complicationData/top-right/
            var scale: Int // 3
            var renderingMode: Int // 0

            private enum CodingKeys: String, CodingKey {
                case file_name = "file name"
                case scale, renderingMode
            }
        }

        struct ChildImageProvider: Codable {
            var onePieceImage: Item?
        }
    }
}

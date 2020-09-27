import Foundation

extension Watchface.Metadata {
    struct CLKSimpleGaugeProvider: Codable {
        var `class`: String = "CLKSimpleGaugeProvider"
        var gaugeFillFraction: Double // 0.581818163394928
        var gaugeStyle: Int // 0
        var gaugeColors: [Color]
        var gaugeColorLocations: [Double]?
    }
}

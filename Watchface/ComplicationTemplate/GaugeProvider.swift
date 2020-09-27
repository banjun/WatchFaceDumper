import Foundation

extension Watchface.Metadata {
    public struct CLKSimpleGaugeProvider: Codable {
        public var `class`: String = "CLKSimpleGaugeProvider"
        /// 0.581818163394928
        public var gaugeFillFraction: Double
        public var gaugeStyle: Int // 0
        public var gaugeColors: [Color]
        public var gaugeColorLocations: [Double]?
    }
}

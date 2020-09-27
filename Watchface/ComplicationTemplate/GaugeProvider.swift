import Foundation

extension Watchface.Metadata {
    public struct CLKSimpleGaugeProvider: Codable {
        public var `class`: String = "CLKSimpleGaugeProvider"
        /// 0.581818163394928
        public var gaugeFillFraction: Double
        public var gaugeStyle: Int // 0
        public var gaugeColors: [Color]
        public var gaugeColorLocations: [Double]?

        public init(`class`: String = "CLKSimpleGaugeProvider", gaugeFillFraction: Double, gaugeStyle: Int, gaugeColors: [Color], gaugeColorLocations: [Double]? = nil) {
            self.class = `class`
            self.gaugeFillFraction = gaugeFillFraction
            self.gaugeStyle = gaugeStyle
            self.gaugeColors = gaugeColors
            self.gaugeColorLocations = gaugeColorLocations
        }
    }
}

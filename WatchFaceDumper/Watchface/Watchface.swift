import Foundation

struct Watchface {
    var metadata: Metadata
    var face: Face
    var snapshot: Data
    var no_borders_snapshot: Data
//    var device_border_snapshot: Data?
    var resources: Resources?
    typealias ComplicationData = Metadata.ComplicationPositionDictionary<[String: Data]> // position -> (filename -> content)
    var complicationData: ComplicationData? = nil
}

import Foundation

public struct Watchface {
    public var metadata: Metadata
    public var face: Face
    public var snapshot: Data
    public var no_borders_snapshot: Data
//    var device_border_snapshot: Data?
    public var resources: Resources?
    public typealias ComplicationData = Metadata.ComplicationPositionDictionary<[String: Data]> // position -> (filename -> content)
    public var complicationData: ComplicationData? = nil
}

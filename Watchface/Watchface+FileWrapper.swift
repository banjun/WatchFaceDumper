import Foundation

public extension Watchface {
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

        let resources: Watchface.Resources?
        if face.resource_directory == true {
            guard let resourcesDirectory = fileWrapper.fileWrappers?["Resources"]?.fileWrappers else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Resources/ not found"))
            }

            guard let resources_metadata_plist = resourcesDirectory["Images.plist"]?.regularFileContents else {
                throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Images.plist not found"))
            }
            let resources_metadata = try PropertyListDecoder().decode(Watchface.Resources.Metadata.self, from: resources_metadata_plist)
            resources = Watchface.Resources(
                images: resources_metadata,
                files: {
                    switch resources_metadata {
                    case .photos(let v): return v.imageList
                            .flatMap {[$0.imageURL, $0.irisVideoURL].compactMap {$0}} // TODO: .pathfinders for kaleidoscope
                            .reduce(into: [:]) {$0[$1] = resourcesDirectory[$1]?.regularFileContents}
                    case .ultraCube(let v): return v.imageList
                            .flatMap {[$0.baseImageURL, $0.backgroundImageURL, $0.maskImageURL].compactMap {$0}}
                            .reduce(into: [:]) {$0[$1] = resourcesDirectory[$1]?.regularFileContents}
                    }
                }())
        } else {
            resources = nil
        }

        let complicationData = fileWrapper.fileWrappers?["complicationData"]

        self.init(
            metadata: metadata,
            face: face,
            snapshot: snapshot,
            no_borders_snapshot: no_borders_snapshot,
//            device_border_snapshot: device_border_snapshot,
            resources: resources,
            complicationData: complicationData.flatMap {Watchface.ComplicationData(fileWrapper: $0)}
        )
    }

    /// check a lossy reading
    func isEqualToFileWrapper(anotherFileWrapper right: FileWrapper) -> Bool {
        guard let left = try? FileWrapper(watchface: self) else { return false }
        guard left.isDirectory == right.isDirectory else { return false }

        func diff(between a: NSDictionary?, and b: NSDictionary?) -> String {
            guard a != b else { return "" }
            return Set((a?.allKeys as? [String] ?? []) + (b?.allKeys as? [String] ?? [])).map { key in
                let av = a?[key] as AnyObject
                let bv = b?[key] as AnyObject
                guard !av.isEqual(bv) else { return nil }
                switch (av, bv) {
                case (let ad as NSDictionary, let bd as NSDictionary): return diff(between: ad, and: bd)
                default: return "- \(key): \(av.debugDescription ?? "(null)")\n+ \(key): \(bv.debugDescription ?? "(null)")"
                }
            }.compactMap {$0}.joined(separator: "\n")
        }

        func isEqualJSONFiles(left: FileWrapper, right: FileWrapper, filename: String) -> Bool {
            let l = left.fileWrappers?[filename]?.regularFileContents.flatMap {try? JSONSerialization.jsonObject(with: $0, options: []) as? NSDictionary}
            let r = right.fileWrappers?[filename]?.regularFileContents.flatMap {try? JSONSerialization.jsonObject(with: $0, options: []) as? NSDictionary}
            if l != r {
                NSLog("%@", "detect differences in \(filename):")
                print("\(diff(between: l, and: r))")
            }
            return l == r
        }
        func isEqualPropertyListFiles(left: FileWrapper, right: FileWrapper, filename: String) -> Bool {
            let l = left.fileWrappers?[filename]?.regularFileContents.flatMap {try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil) as? NSDictionary}
            let r = right.fileWrappers?[filename]?.regularFileContents.flatMap {try? PropertyListSerialization.propertyList(from: $0, options: [], format: nil) as? NSDictionary}
            if l != r {
                NSLog("%@", "detect differences in \(filename):")
                print("\(diff(between: l, and: r))")
            }
            return l == r
        }
        func isEqualDataFiles(left: FileWrapper, right: FileWrapper, filename: String) -> Bool {
            let l = left.fileWrappers?[filename]?.regularFileContents
            let r = right.fileWrappers?[filename]?.regularFileContents
            if l != r {
                NSLog("%@", "detect differences in \(filename):\nleft: \(l.debugDescription)\nright: \(r.debugDescription)")
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
        for (filename, _) in resources?.files ?? [:] {
            guard isEqualDataFiles(left: leftResources, right: rightResources, filename: filename) else { return false }
        }

        return true
    }
}

public extension Watchface.ComplicationData {
    init?(fileWrapper: FileWrapper) {
        guard let positions = fileWrapper.fileWrappers else { return nil }
        self.init()
        CodingKeys.allCases.forEach {
            self[$0] = positions[$0.rawValue]?.fileWrappers?.compactMapValues {$0.regularFileContents}
        }
    }
}

public extension FileWrapper {
    convenience init(watchface: Watchface) throws {
        self.init(directoryWithFileWrappers: [
            "face.json": FileWrapper(regularFileWithContents: try JSONEncoder().encode(watchface.face)),
            "metadata.json": FileWrapper(regularFileWithContents: try JSONEncoder().encode(watchface.metadata)),
            "snapshot.png": FileWrapper(regularFileWithContents: watchface.snapshot),
            "no_borders_snapshot.png": FileWrapper(regularFileWithContents: watchface.no_borders_snapshot),
            //            "device_border_snapshot.png": watchface.device_border_snapshot.map {FileWrapper(regularFileWithContents: $0)},
            "Resources": try watchface.resources.map {try FileWrapper(resources: $0)},
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

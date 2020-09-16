import AVKit


final class EditableAVPlayerView: AVPlayerView, AVAssetResourceLoaderDelegate {
    private var asset: AVURLAsset? {
        didSet {
            asset?.resourceLoader.setDelegate(self, queue: .main)
            player = asset.map {AVPlayer(playerItem: AVPlayerItem(asset: $0))}
        }
    }
    var data: Data? {
        didSet {
            asset = AVURLAsset(url: URL(string: "data://")!)
            dataDidChange?(data)
        }
    }
    var dataDidChange: ((Data?) -> Void)?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        .copy
    }
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let data = (NSURL(from: sender.draggingPasteboard).flatMap {try? Data(contentsOf: $0 as URL)}) else { return false }
        self.data = data
        return true
    }

    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        guard let data = self.data else { return true }
        loadingRequest.contentInformationRequest?.contentType = "com.apple.quicktime-movie"
        loadingRequest.contentInformationRequest?.contentLength = Int64(data.count)
        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
        if let dataRequest = loadingRequest.dataRequest {
            dataRequest.respond(with: data[(dataRequest.requestedOffset)..<(dataRequest.requestedOffset + Int64(dataRequest.requestedLength))])
        }
        loadingRequest.finishLoading()
        return true
    }
}

import AVKit


final class EditableAVPlayerView: AVPlayerView, AVAssetResourceLoaderDelegate {
    private var durationObservation: NSKeyValueObservation? {
        didSet {
            oldValue?.invalidate()
        }
    }
    private var asset: AVURLAsset? {
        didSet {
            asset?.resourceLoader.setDelegate(self, queue: .main)
            let item = asset.map {AVPlayerItem(asset: $0)}
            player = item.map {AVPlayer(playerItem: $0)}
            durationObservation = item?.observe(\.duration) { [weak self] item, _ in
                let duration = item.duration.seconds
                guard let self = self, duration > 0, let data = self.data, duration != self.movie?.duration else { return }
                self.movie = Movie(data: data, duration: duration)
            }
        }
    }
    var movie: Movie? {
        didSet {
            asset = AVURLAsset(url: URL(string: "data://")!)
            self.movieDidChange?(movie)
        }
    }
    var data: Data? {
        get {movie?.data}
        set {
            asset = AVURLAsset(url: URL(string: "data://")!)
            if let data = newValue {
                let movie = Movie(data: data, duration: nil)
                self.movie = movie
            } else {
                self.movie = nil
            }
        }
    }
    struct Movie: Equatable {
        var data: Data
        var duration: Double?
    }
    var movieDidChange: ((Movie?) -> Void)?

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

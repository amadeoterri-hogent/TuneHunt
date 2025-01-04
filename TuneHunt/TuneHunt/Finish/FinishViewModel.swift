import Foundation
import SwiftUI
import Combine
import SpotifyWebAPI

class FinishViewModel<Items: Codable & Hashable> : ObservableObject {
    let spotify: Spotify = Spotify.shared
    
    @Published private var finishModel: FinishModel<Items> = FinishModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigateProgress = false
    @Published var shouldNavigateHome = false
    @Published var loadedPlaylist: Playlist<PlaylistItems>? = nil
    
    private var loadPlaylistCancellable: AnyCancellable? = nil
    private var loadImageCancellables: [AnyCancellable] = []
    
    init(){}
    
    init(finishModel: FinishModel<Items>) {
        self.finishModel = finishModel
    }
    
    var tracks: [Track] {
        self.finishModel.getTracksFromTrackResults()
    }
    
    var trackResults: [FinishModel<Items>.TrackResult] {
        self.finishModel.trackResults
    }
    
    var selectedPlaylist: PlaylistModel<Items>.UserPlaylist? {
        self.finishModel.selectedPlaylist
    }
    
    func setSelectedPlaylist(_ userPlaylist: PlaylistModel<Items>.UserPlaylist) {
        self.finishModel.setSelectedPlaylist(userPlaylist)
    }
    
    func setTracks(_ tracks: [Track]) {
        self.finishModel.setTracks(tracks)
    }
    
    func loadPlaylist() {
        if let selectedPlaylist = finishModel.selectedPlaylist {
            self.loadPlaylistCancellable =  spotify.api.playlist(selectedPlaylist.playlist)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { _ in },
                    receiveValue: { playlist in
                        self.loadedPlaylist = playlist
                    }
                )
        }
    }
    
    func loadImage(for trackResult: FinishModel<Items>.TrackResult) {
        if trackResult.image != nil {
            return
        }
        
        guard let spotifyImage = trackResult.track.album?.images?.largest else {
            return
        }
        
        let cancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.finishModel.updateImageOfTrackResult(for: trackResult, image: image)
                }
            )
        
        loadImageCancellables.append(cancellable)
    }
}

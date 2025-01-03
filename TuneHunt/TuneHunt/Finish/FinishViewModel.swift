import Foundation
import SwiftUI
import Combine
import SpotifyWebAPI

class FinishViewModel: ObservableObject {
    let spotify: Spotify = Spotify.shared
    
    @Published var finishModel: FinishModel = FinishModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigateProgress = false
    @Published var shouldNavigateHome = false
    @Published var progress: Double = 0.0
    @Published var animationAmount: Double = 1.0
    @Published var loadedPlaylist: Playlist<PlaylistItems>? = nil
    
    private var loadPlaylistCancellable: AnyCancellable? = nil
    
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
}

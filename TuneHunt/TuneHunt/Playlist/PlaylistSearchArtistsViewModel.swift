import Foundation
import Combine
import SpotifyWebAPI

class PlaylistSearchArtistsViewModel: ObservableObject {
    let spotify: Spotify = Spotify.shared

    @Published var playlistSearchArtistsModel: PlaylistSearchArtistsModel = PlaylistSearchArtistsModel()
    @Published var isSearching = false
    @Published var searchText = ""
    @Published var shouldNavigate = false
    @Published var alertItem: AlertItem? = nil
    @Published var searchCancellables: [AnyCancellable] = []
    @Published var artistsCancellables: Set<AnyCancellable> = []
    @Published var loadPlaylistCancellable: AnyCancellable? = nil
        
    var playlists: [Playlist<PlaylistItemsReference>] {
        self.playlistSearchArtistsModel.playlists
    }
    
    func searchPlaylist() {
        if ProcessInfo.processInfo.isPreviewing {
            return
        }
        
        if !validate() {
            return
        }
        
        self.playlistSearchArtistsModel.clearPlaylists()
        self.isSearching = true
        
        let cancellable = spotify.api.search(
            query: self.searchText, categories: [.playlist]
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.alertItem = AlertItem(
                        title: "Couldn't Perform Search",
                        message: error.localizedDescription
                    )
                }
                self.isSearching = false
            },
            receiveValue: { searchResults in
                let playlists = searchResults.playlists?.items ?? []
                self.playlistSearchArtistsModel.updatePlaylists(playlists)
            }
        )
        self.searchCancellables.append(cancellable)
    }
    
    func findArtists(playlist: Playlist<PlaylistItemsReference>, artistSearchResultViewModel: ArtistSearchResultViewModel) {
        self.isSearching = true
        self.loadPlaylistCancellable =  spotify.api.playlistItems(playlist.uri)
            .extendPagesConcurrently(self.spotify.api)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion:{ _ in },
                receiveValue: { page in
                    self.addArtistsFromPlaylist(page: page, artistSearchResultViewModel: artistSearchResultViewModel)
                }
            )
    }
    
    func addArtistsFromPlaylist(page: PlaylistItems, artistSearchResultViewModel: ArtistSearchResultViewModel) {
        let playlistItems = page.items.compactMap(\.item)
        var remainingRequests = 0

        for playlistItem in playlistItems {
            guard case .track(let track) = playlistItem else { continue }
            
            for artist in track.artists ?? [] {
                guard let uri = artist.uri,
                      !artistSearchResultViewModel.artistResult.artistSearchResults.contains(where: { $0.artist.id == artist.id }) else { continue }
                
                remainingRequests += 1

                spotify.api.artist(uri)
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.alertItem = AlertItem(
                                    title: "Couldn't Perform Search",
                                    message: error.localizedDescription
                                )
                            }
                            remainingRequests -= 1
                            if remainingRequests == 0 {
                                self.isSearching = false
                                self.shouldNavigate = true
                            }
                        },
                        receiveValue: { artist in
                            if !artistSearchResultViewModel.artistResult.artistSearchResults.contains(where: { $0.artist.id == artist.id }) {
                                artistSearchResultViewModel.artistResult.artistSearchResults.append(ArtistModel.ArtistSearchResult(artist: artist))
                            }
                        }
                    )
                    .store(in: &artistsCancellables)
            }
        }

        if remainingRequests == 0 {
            self.isSearching = false
            self.shouldNavigate = true
        }
    }
    
    func clear() {
        self.searchText = ""
        self.playlistSearchArtistsModel.clearPlaylists()
    }
    
    func validate() -> Bool {
        if self.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.alertItem = AlertItem(
                title: "Couldn't search playlist",
                message: "Playlist name is empty."
            )
            return false
        }

        guard spotify.currentUser?.uri != nil else {
            self.alertItem = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return false
        }

        return true
    }
    
}

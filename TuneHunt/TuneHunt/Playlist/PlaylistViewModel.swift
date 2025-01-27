import Foundation
import SpotifyWebAPI
import Combine

class PlaylistViewModel: ObservableObject {
    let spotify: Spotify = Spotify.shared
    
    @Published private var playlistModel: PlaylistModel<PlaylistItemsReference> = PlaylistModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate: Bool = false
    @Published var showCreatePlaylist: Bool = false
    @Published var loadingImages: Set<String> = []
    @Published var newPlaylistName: String = ""
    @Published var isLoading = false
    @Published var isSearchingTracks = false
    @Published var createdPlaylist: Playlist<PlaylistItems>? = nil
    
    private var cancellables: Set<AnyCancellable> = []
    private var searchCancellables: Set<AnyCancellable> = []
    private var createPlaylistCancellable: AnyCancellable?
    private var topTracks = UserDefaults.standard.integer(forKey: "topTracks")
    private var selectedCountryCode: String = UserDefaults.standard.string(forKey: "Country") ?? "BE"
    private var loadImageCancellables: [AnyCancellable] = []
    
    init() {}
    
    init(playlistModel: PlaylistModel<PlaylistItemsReference>) {
        self.playlistModel = playlistModel
    }
    
    var selectedPlaylist: Playlist<PlaylistItems>? {
        self.playlistModel.selectedPlaylist
    }
    
    var tracks: [Track] {
        self.playlistModel.tracks
    }
    
    var artists: [Artist] {
        self.playlistModel.artists
    }
    
    var userPlaylists: [PlaylistModel<PlaylistItemsReference>.UserPlaylist] {
        self.playlistModel.userPlaylists
    }
    
    func setArtists(_ artists: [Artist]) {
        self.playlistModel.setArtists(artists)
    }
    
    func addPlaylist(_ playlist: Playlist<PlaylistItemsReference>) {
        self.playlistModel.addPlaylist(playlist: playlist)
    }
    
    func setUserPlaylists(_ playlists: [PlaylistModel<PlaylistItemsReference>.UserPlaylist]) {
        self.playlistModel.setUserPlaylists(playlists)
    }
    
    func hasPlaylists() -> Bool {
        return !self.playlistModel.userPlaylists.isEmpty
    }
    
    func retrievePlaylists() {
        if ProcessInfo.processInfo.isPreviewing { return }
        
        self.isLoading = true
        self.playlistModel.userPlaylists = []
        
        spotify.api.currentUserPlaylists(limit: 50)
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.alertItem = AlertItem(
                            title: "Couldn't Perform Search",
                            message: error.localizedDescription
                        )
                    }
                    self.isLoading = false
                },
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items
                    self.playlistModel.addPlaylists(playlists: playlists)
                }
            )
            .store(in: &cancellables)
    }
    
    func searchTopTracks(userPlaylist: PlaylistModel<PlaylistItemsReference>.UserPlaylist, finishViewModel: FinishViewModel<PlaylistItemsReference>) {
        if ProcessInfo.processInfo.isPreviewing { return }
        
        self.isSearchingTracks = true
        
        self.playlistModel.clearTracks()
        var remainingRequests = self.playlistModel.artists.count
        
        for artist in self.playlistModel.artists {
            if let uri = artist.uri {
                spotify.api.artistTopTracks(uri, country: selectedCountryCode)
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
                                self.playlistModel.removeDuplicatesFromTracks()
                                finishViewModel.setSelectedPlaylist(userPlaylist)
                                finishViewModel.setTracks(self.playlistModel.tracks)
                                self.isSearchingTracks = false
                                if finishViewModel.selectedPlaylist != nil && !finishViewModel.tracks.isEmpty {
                                    self.shouldNavigate = true
                                } else {
                                    self.alertItem = AlertItem(
                                        title: "Couldn't Resume",
                                        message: "Playlist or tracks are empty"
                                    )
                                }
                                
                            }
                        },
                        receiveValue: { searchResults in
                            let topTracks = searchResults.prefix(self.topTracks)
                            for track in topTracks {
                                self.playlistModel.addTrack(track:track)
                            }
                        }
                    )
                    .store(in: &searchCancellables)
            } else {
                // Handle artists without a URI (optional improvement)
                remainingRequests -= 1
                if remainingRequests == 0 {
                    self.playlistModel.removeDuplicatesFromTracks()
                    self.isSearchingTracks = false
                    self.shouldNavigate = true
                }
            }
        }
    }
    
    func loadImage(for userPlaylist: PlaylistModel<PlaylistItemsReference>.UserPlaylist) {
        guard let spotifyImage = userPlaylist.playlist.images.largest else {
            return
        }
        
        let cancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.playlistModel.updateImageOfUserPlaylist(userPlaylist, image: image)
                }
            )
        
        self.loadImageCancellables.append(cancellable)
        
    }
    
    func createPlaylist() {
        if ProcessInfo.processInfo.isPreviewing { return }
        
        if !validate() {
            return
        }
        
        let playlistDetails = PlaylistDetails(
            name: self.newPlaylistName,
            isPublic: true,
            isCollaborative: false
        )
        
        guard let userURI = spotify.currentUser?.uri else {
            self.alertItem = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return
        }
        
        createPlaylistCancellable = spotify.api.createPlaylist(for: userURI, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Playlist created successfully.")
                        self.showCreatePlaylist = false
                    case .failure(let error):
                        print("Failed to create playlist: \(error)")
                        self.alertItem = AlertItem(
                            title: "Failed to create playlist",
                            message: "There went something wrong while creating a playlist."
                        )
                    }
                },
                receiveValue: { playlist in
                    // Create a new Playlist<PlaylistItemsReference>
                    let playlistReference = Playlist<PlaylistItemsReference>(
                        name: playlist.name,
                        items: PlaylistItemsReference(href: playlist.items.href, total: 0),
                        owner: playlist.owner,
                        isPublic: playlist.isPublic,
                        isCollaborative: playlist.isCollaborative,
                        description: playlist.description,
                        snapshotId: playlist.snapshotId,
                        externalURLs: playlist.externalURLs,
                        followers: playlist.followers,
                        href: playlist.href,
                        id: playlist.id,
                        uri: playlist.uri,
                        images: playlist.images
                    )
                    self.playlistModel.addPlaylist(playlist: playlistReference)
                }
            )
        
        
    }
    
    func validate() -> Bool {
        if self.newPlaylistName == "" {
            self.alertItem = AlertItem(
                title: "Couldn't create playlist",
                message: "Playlist name is empty."
            )
            return false
        }
        
        return true
    }
}

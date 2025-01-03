import Foundation
import SpotifyWebAPI
import Combine

class PlaylistViewModel: ObservableObject {
    let spotify: Spotify = Spotify.shared

    @Published var playlistModel: PlaylistModel = PlaylistModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate: Bool = false
    @Published var showCreatePlaylist: Bool = false
    @Published var loadingImages: Set<String> = []
    @Published var newPlaylistName: String = ""
    @Published var isLoading = false
    @Published var isSearchingTracks = false

    @Published private var cancellables: Set<AnyCancellable> = []
    @Published private var searchCancellables: Set<AnyCancellable> = []
    @Published private var loadPlaylistCancellable: AnyCancellable? = nil
    @Published private var showingAlert = false
    @Published private var createPlaylistCancellable: AnyCancellable?
    @Published private var createdPlaylist: Playlist<PlaylistItems>? = nil
    
    private var topTracks = UserDefaults.standard.integer(forKey: "topTracks")
    private var selectedCountryCode: String = UserDefaults.standard.string(forKey: "Country") ?? "BE"
    private var loadImageCancellables: [AnyCancellable] = []
    
    init() {}
    
    init(playlistModel: PlaylistModel) {
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
    
    var getPlaylists: [PlaylistModel.UserPlaylist] {
        self.playlistModel.userPlaylists
    }
    
    func addPlaylist(_ playlist: Playlist<PlaylistItemsReference>) {
        self.playlistModel.addPlaylist(playlist: playlist)
    }
    
    func setUserPlaylists(_ playlists: [PlaylistModel.UserPlaylist]) {
        self.playlistModel.setUserPlaylists(playlists)
    }
    
    func hasPlaylists() -> Bool {
        return !self.playlistModel.userPlaylists.isEmpty
    }
    
    func retrievePlaylists() {
        // Don't try to load any playlists if we're in preview mode.
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
    
    func loadPlaylist(selectedPlaylist: Playlist<PlaylistItemsReference>) {
        self.isSearchingTracks = true
        self.loadPlaylistCancellable =  spotify.api.playlist(selectedPlaylist)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion:{ _ in
                    self.searchTopTracks()
                },
                receiveValue: { playlist in
                    self.playlistModel.selectedPlaylist = playlist
                }
            )
    }
    
    func searchTopTracks() {
        if ProcessInfo.processInfo.isPreviewing { return }
        
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
                                self.isSearchingTracks = false
                                self.shouldNavigate = true
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
    
    func loadImage(for userPlaylist: PlaylistModel.UserPlaylist) {       
        print("Loading image for playlist with name: \(userPlaylist.playlist.name)")

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
    
    func createPlaylist(){
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

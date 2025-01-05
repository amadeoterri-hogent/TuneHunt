import SpotifyWebAPI

struct PlaylistSearchArtistsModel {
    private(set) var playlists: [Playlist<PlaylistItemsReference>] = []
    
    init() {}
    
    init(playlists: [Playlist<PlaylistItemsReference>]) {
        self.playlists = playlists
    }
    
    mutating func updatePlaylists(_ newPlaylists: [Playlist<PlaylistItemsReference>]) {
        self.playlists = newPlaylists
    }
    
    mutating func clearPlaylists() {
        self.playlists = []
    }
}

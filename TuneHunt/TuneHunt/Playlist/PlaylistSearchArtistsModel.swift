import SpotifyWebAPI

struct PlaylistSearchArtistsModel {
    private(set) var playlists: [Playlist<PlaylistItemsReference>] = []
    
    mutating func updatePlaylists(_ newPlaylists: [Playlist<PlaylistItemsReference>]) {
        self.playlists = newPlaylists
    }
    
    mutating func clearPlaylists() {
        self.playlists = []
    }
}

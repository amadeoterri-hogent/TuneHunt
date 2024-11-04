import SpotifyWebAPI

struct ArtistSearchResult {
    var id: String?
    var artist: Artist
    var addToPlaylist: Bool = true
    
    init(artist: Artist) {
        self.id = artist.id
        self.artist = artist
    }
}

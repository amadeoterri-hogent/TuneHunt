import SpotifyWebAPI
import SwiftUI

struct ArtistSearchResult {
    var id: String?
    var artist: Artist
    var addToPlaylist: Bool = true
    var image: Image? = nil
    
    init(artist: Artist) {
        self.id = artist.id
        self.artist = artist
    }
}

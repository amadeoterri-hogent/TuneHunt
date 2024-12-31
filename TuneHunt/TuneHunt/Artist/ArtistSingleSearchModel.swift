import Foundation
import SpotifyWebAPI
import Combine

struct ArtistSingleSearchModel {
    var artists: [Artist] = []
    var selectedArtists: [Artist] = []
    
    mutating func select(_ artist: Artist) {
        self.selectedArtists = [artist]
    }
    
}

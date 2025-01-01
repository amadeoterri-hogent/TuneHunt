import Foundation
import SpotifyWebAPI
import Combine
import SwiftUI

struct SearchArtistModel {
    private(set) var artists: [Artist] = []
    private(set) var selectedArtists: [Artist] = []
    private(set) var artistSearchResults: [ArtistSearchResult] = []
    
    let separators = ["Auto","Comma", "Space", "Newline"]
    
    mutating func select(_ artist: Artist) {
        self.selectedArtists = [artist]
    }
    
    mutating func addArtistToArtistSearchResults(artist: Artist) {
        if !self.artistSearchResults.contains(where: { $0.artist.id == artist.id }) {
            self.artistSearchResults.append(SearchArtistModel.ArtistSearchResult(artist: artist))
        }
    }
    
    mutating func updateArtists(_ newArtists: [Artist]) {
        self.artists = newArtists
    }
    
    mutating func clearArtists() {
        self.artists = []
    }
    
    mutating func clearArtistSearchResults() {
        self.artistSearchResults = []
    }
    
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
    
}

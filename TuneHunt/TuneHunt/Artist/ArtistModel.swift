import SpotifyWebAPI
import SwiftUI

struct ArtistModel{
    var artistSearchResults: [ArtistSearchResult] = []
    
    init() {}
    
    init(artistSearchResults: [ArtistSearchResult]) {
        self.artistSearchResults = artistSearchResults
    }
    
    mutating func addArtistToArtistSearchResults(artist: Artist) {
        if !self.artistSearchResults.contains(where: { $0.artist.id == artist.id }) {
            self.artistSearchResults.append(ArtistModel.ArtistSearchResult(artist: artist))
        }
    }
    
    var selectAll: Bool {
        get {
            artistSearchResults.allSatisfy { $0.addToPlaylist }
        }
        set {
            for index in artistSearchResults.indices {
                artistSearchResults[index].addToPlaylist = newValue
            }
        }
    }
    
    mutating func clearArtistSearchResults() {
        self.artistSearchResults = []
    }
    
    mutating func updateImageOfArtistSearchResult(for artistSearchResult: ArtistSearchResult, image: Image?) {
        if let index = artistSearchResults.firstIndex(where: { $0.id == artistSearchResult.id }) {
            artistSearchResults[index].updateImage(image)
        }
    }
    
    func getArtistsFromArtistSearchResults() -> [Artist] {
        self.artistSearchResults
            .filter { $0.addToPlaylist }
            .map { $0.artist }
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
        
        mutating func updateImage(_ image: Image?) {
            self.image = image
        }
    }
}


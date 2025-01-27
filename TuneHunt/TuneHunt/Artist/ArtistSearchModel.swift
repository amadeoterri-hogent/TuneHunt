import SpotifyWebAPI

struct ArtistSearchModel {
    private(set) var artists: [Artist] = []
    private(set) var selectedArtists: [Artist] = []
    
    let separators = ["Auto","Comma", "Space", "Newline"]
    
    init() {}
    
    init(artists: [Artist]) {
        self.artists = artists
    }
    
    mutating func select(_ artist: Artist) {
        self.selectedArtists = [artist]
    }
    
    mutating func updateArtists(_ newArtists: [Artist]) {
        self.artists = newArtists
    }
    
    mutating func clearArtists() {
        self.artists = []
    }
    
}

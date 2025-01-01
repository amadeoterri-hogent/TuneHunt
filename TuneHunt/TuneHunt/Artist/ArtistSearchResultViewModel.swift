import Foundation
import SpotifyWebAPI
import Combine

class ArtistSearchResultViewModel: ObservableObject {
    @Published var artistResult: ArtistResult = ArtistResult()
    @Published var loadingImages: Set<String> = []
    
    var didRequestImage = false
    var loadImageCancellable: AnyCancellable? = nil
    var shouldNavigate = false
    var spotifyArtists: [Artist] = []
    
    var getArtists: [Artist] {
        self.artistResult.getArtistsFromArtistSearchResults()
    }
    
    func clearArtistSearchResults() {
        self.artistResult.clearArtistSearchResults()
    }
    
    func addArtistToArtistSearchResults(artist: Artist) {
        self.artistResult.addArtistToArtistSearchResults(artist: artist)
    }
    
    var selectAll: Bool {
        get {
            self.artistResult.selectAll
        }
        set {
            self.artistResult.selectAll = newValue
            objectWillChange.send()
        }
    }
    
    func loadImage(for artistSearchResult: ArtistResult.ArtistSearchResult) {
        if let id = artistSearchResult.id {
            if !loadingImages.contains(id) {
                self.loadingImages.insert(id)
            } else {
                return
            }
        }
        
        guard let spotifyImage = artistSearchResult.artist.images?.largest else {
            return
        }
        
        self.loadImageCancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.artistResult.updateImageOfArtistSearchResult(for: artistSearchResult, image: image)
                }
            )
    }
}

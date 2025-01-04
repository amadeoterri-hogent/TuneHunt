import Foundation
import SpotifyWebAPI
import Combine

class ArtistSearchResultViewModel: ObservableObject {
    @Published var artistResult: ArtistModel = ArtistModel()
    @Published var shouldNavigate = false
    
    var spotifyArtists: [Artist] = []
    
    private var loadImageCancellables: [AnyCancellable] = []
    
    var artists: [Artist] {
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
    
    func loadImage(for artistSearchResult: ArtistModel.ArtistSearchResult) {
        if artistSearchResult.image != nil {
            return
        }
        
        guard let spotifyImage = artistSearchResult.artist.images?.largest else {
            return
        }
        
        let cancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.artistResult.updateImageOfArtistSearchResult(for: artistSearchResult, image: image)
                }
            )
        
        loadImageCancellables.append(cancellable)
    }
}

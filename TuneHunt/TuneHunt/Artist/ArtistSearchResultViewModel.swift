import Foundation
import SpotifyWebAPI
import Combine

class ArtistSearchResultViewModel: ObservableObject {
    @Published private var artistModel: ArtistModel = ArtistModel()
    @Published var shouldNavigate = false
    @Published var alertItem: AlertItem? = nil
    
    var spotifyArtists: [Artist] = []
    
    private var loadImageCancellables: [AnyCancellable] = []
    
    init() {}
    
    init(artistModel: ArtistModel) {
        self.artistModel = artistModel
    }
    
    var artists: [Artist] {
        self.artistModel.getArtistsFromArtistSearchResults()
    }
    
    var artistSearchResults: [ArtistSearchResult] {
        self.artistModel.artistSearchResults
    }
    
    func clearArtistSearchResults() {
        self.artistModel.clearArtistSearchResults()
    }
    
    func addArtistToArtistSearchResults(artist: Artist) {
        self.artistModel.addArtistToArtistSearchResults(artist: artist)
    }
    
    func updateAddToPlaylist(for artistSearchResult: ArtistSearchResult, isSelected: Bool) {
        self.artistModel.updateAddToPlaylist(for: artistSearchResult, isSelected: isSelected)
    }
    
    var selectAll: Bool {
        get {
            self.artistModel.selectAll
        }
        set {
            self.artistModel.selectAll = newValue
            objectWillChange.send()
        }
    }
    
    func loadImage(for artistSearchResult: ArtistSearchResult) {
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
                    self.artistModel.updateImageOfArtistSearchResult(for: artistSearchResult, image: image)
                }
            )
        
        loadImageCancellables.append(cancellable)
    }
}

import Foundation
import SpotifyWebAPI
import Combine

class ArtistSingleSearchViewModel: ObservableObject {
    let spotify: Spotify
    var searchText: String = ""
    var isSearching = false
    var isPreview: Bool
    private var searchCancellable: AnyCancellable? = nil
    
    init(spotify: Spotify, isPreview: Bool) {
        self.spotify = spotify
        self.isPreview = isPreview
    }
    
    @Published private var model = ArtistSingleSearchModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate = false
    
    var artists: [Artist] {
        self.model.artists
    }
    
    var selectedArtists: [Artist] {
        self.model.selectedArtists
    }
    
    func select(_ artist: Artist) {
        self.model.select(artist)
        self.shouldNavigate = true
    }
    
    func search() {
        if isPreview {
            self.model.artists = [.pinkFloyd,.radiohead]
            return
        }
        
        if !validate() {
            return
        }
        
        self.isSearching = true

        self.searchCancellable = spotify.api.search(
            query: self.searchText, categories: [.artist]
        )
        .receive(on: RunLoop.main)
        .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.alertItem = AlertItem(
                            title: "Couldn't Perform Search",
                            message: error.localizedDescription
                        )
                    }
                    self.isSearching = false
                }, receiveValue: { searchResults in
                self.model.artists  = searchResults.artists?.items ?? []
            }
        )
    }
    
    func clear() -> Void {
        self.searchText = ""
        self.model.artists = []
    }
    
    func validate() -> Bool {
        if self.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.alertItem = AlertItem(
                title: "Couldn't search artist",
                message: "Artist name is empty."
            )
            return false
        }

        guard spotify.currentUser?.uri != nil else {
            self.alertItem = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return false
        }

        return true
    }
}

import Foundation
import SpotifyWebAPI
import Combine

class SearchArtistViewModel: ObservableObject {
    @Published private var model = SearchArtistModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate = false
    @Published var showArtistsPreview = false

    let spotify: Spotify = Spotify.shared
    var searchText: String = ""
    var artistSearchValueSplit: String = ""
    var isSearching = false
    var selectedSeparator = "Auto"
    private var searchCancellables: [AnyCancellable] = []
    var artistsPreview: [String] = []
    
    init() {}
    
    var artists: [Artist] {
        self.model.artists
    }
    
    var selectedArtists: [Artist] {
        self.model.selectedArtists
    }
    
    var artistSearchResults: [SearchArtistModel.ArtistSearchResult] {
        self.model.artistSearchResults
    }
    
    var separators: [String] {
        self.model.separators
    }
    
    func select(_ artist: Artist) {
        self.model.select(artist)
        self.shouldNavigate = true
    }
    
    func searchSingleArtist() {
        if ProcessInfo.processInfo.isPreviewing {
            self.model.updateArtists([.pinkFloyd,.radiohead])
            return
        }
        
        if !validate() {
            return
        }
        
        self.isSearching = true

        let cancellable = spotify.api.search(
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
                    let artists  = searchResults.artists?.items ?? []
                    self.model.updateArtists(artists)
            }
        )
        self.searchCancellables.append(cancellable)
    }
    
    func searchMultipleArtists() {
        guard !artistsPreview.isEmpty else {
            self.alertItem = AlertItem(
                title: "Couldn't Perform Search",
                message: "No artists where found."
            )
            return
        }
        
        self.model.clearArtistSearchResults()
        self.isSearching = true
        let artistNames = artistsPreview
        var remainingSearches = Double(artistNames.count)
        
        for artist in artistNames {
            let cancellable = spotify.api.search(
                query: artist, categories: [.artist]
            )
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        // Only navigate when all artists have been searched in Spotify
                        remainingSearches -= 1
                        if remainingSearches == 0 {
                            self.isSearching = false
                            self.shouldNavigate = true
                        }
                        if case .failure(let error) = completion {
                            self.alertItem = AlertItem(
                                title: "Couldn't Perform Search",
                                message: error.localizedDescription
                            )
                        }
                    },
                    receiveValue: { searchResults in
                        // Add the first result to the list of artists to send to the next screen
                        if let artist = searchResults.artists?.items.first {
                            self.model.addArtistToArtistSearchResults(artist: artist)
                        }
                    }
                )
            self.searchCancellables.append(cancellable)
        }
    }
    
    func splitArtists() -> Void {
        let separator: Character
        self.artistSearchValueSplit = searchText
        switch selectedSeparator {
        case "Auto":
            self.artistSearchValueSplit = self.artistSearchValueSplit
                .replacingOccurrences(of: "•", with: ",")
                .replacingOccurrences(of: "-", with: ",")
                .replacingOccurrences(of: "\n", with: ",")
            separator = ","
        case "Comma":
            separator = ","
        case "Space":
            separator = " "
        case "Newline":
            separator = "\n"
        default:
            separator = " "
        }
        self.artistsPreview = self.artistSearchValueSplit
            .split(separator: separator)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removingDuplicates()
    }
    
    func removeArtist(at offsets: IndexSet) {
        self.artistsPreview.remove(atOffsets: offsets)
    }
    
    func clear() -> Void {
        self.searchText = ""
        self.artistSearchValueSplit = ""
        self.artistsPreview = []
        self.model.clearArtists()
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

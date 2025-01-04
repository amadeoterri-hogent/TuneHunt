import Foundation
import SpotifyWebAPI
import Combine

class ArtistSearchViewModel: ObservableObject {
    @Published private var artistSearchModel = ArtistSearchModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate = false
    @Published var showArtistsPreview = false
    @Published var searchText = ""
    @Published var artistsPreview: [String] = []
    @Published var selectedSeparator = "Auto"
    @Published var isSearching = false

    private var spotify: Spotify = Spotify.shared
    private var artistSearchValueSplit: String = ""
    private var searchCancellables: [AnyCancellable] = []
    
    init() {}
    
    init(spotify: Spotify) {
        self.spotify = spotify
    }
    
    var artists: [Artist] {
        self.artistSearchModel.artists
    }
    
    var selectedArtists: [Artist] {
        self.artistSearchModel.selectedArtists
    }
    
    var separators: [String] {
        self.artistSearchModel.separators
    }
    
    func select(_ artist: Artist) {
        self.artistSearchModel.select(artist)
        self.shouldNavigate = true
    }
    
    func searchSingleArtist() {
        if ProcessInfo.processInfo.isPreviewing {
            self.artistSearchModel.updateArtists([.pinkFloyd,.radiohead])
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
                    self.artistSearchModel.updateArtists(artists)
            }
        )
        self.searchCancellables.append(cancellable)
    }
    
    func searchMultipleArtists(artistSearchResultViewModel: ArtistSearchResultViewModel) {
        guard !artistsPreview.isEmpty else {
            self.alertItem = AlertItem(
                title: "Couldn't Perform Search",
                message: "No artists where found."
            )
            return
        }
        
        artistSearchResultViewModel.clearArtistSearchResults()
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
                            artistSearchResultViewModel.addArtistToArtistSearchResults(artist: artist)
                        }
                    }
                )
            self.searchCancellables.append(cancellable)
        }
    }
    
    func splitArtists() {
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
    
    func clear() {
        self.searchText = ""
        self.artistSearchValueSplit = ""
        self.artistsPreview = []
        self.artistSearchModel.clearArtists()
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

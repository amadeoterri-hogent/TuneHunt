import SwiftUI
import Combine
import SpotifyWebAPI

struct PlayListView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var searchText: String = ""
    @State var artists: [Artist] = []
    @State private var selectedSeparator = "Comma"
    @State private var isSearching = false
    @State private var searchCancellables: [AnyCancellable] = []
    @State private var alertItem: AlertItem? = nil
    @State private var navigateToResults = false  // Controls navigation to the results view

    let separators = ["Comma", "Space", "Newline"]

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Enter artists here...", text: $searchText)
                        .disableAutocorrection(true)
                }
                
                Section {
                    Picker("Separator", selection: $selectedSeparator) {
                        ForEach(separators, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Select a separator:")
                }
                
                Section {
                    // List of artists
                    ForEach(splitArtists(), id: \.self) { artist in
                        Text(artist)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(5)
                    }
                }
                
                Button("Search", action: searchArtist)
                    .disabled(isSearching || searchText.isEmpty)
                
                Section(header: Text("Result")) {
                    if isSearching {
                        ProgressView("Searching...")
                    } else if artists.isEmpty {
                        Text("No artists found")
                    } else {
                        ForEach(artists, id: \.id) { artist in
                            Text(artist.name)
                        }
                    }
                }
                
            }
        }
    }
    
    // Function to split artists based on selected separator
    private func splitArtists() -> [String] {
        let separator: Character
        switch selectedSeparator {
        case "Comma":
            separator = ","
        case "Space":
            separator = " "
        case "Newline":
            separator = "\n"
        default:
            separator = " "
        }
        return searchText
            .split(separator: separator)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    func searchArtist() {

        self.artists = []
        
        let artistNames = splitArtists()
        
        guard !artistNames.isEmpty else { return }
        self.isSearching = true
        
        for artist in artistNames {
            
            let cancellable = spotify.api.search(
                query: artist, categories: [.artist]
            )
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isSearching = false
                    if case .failure(let error) = completion {
                        self.alertItem = AlertItem(
                            title: "Couldn't Perform Search",
                            message: error.localizedDescription
                        )
                    }
                },
                receiveValue: { searchResults in
                    if let artist = searchResults.artists?.items.first {
                        self.artists.append(artist)
                    }
                }
            )
            
            self.searchCancellables.append(cancellable)
            
        }
        

    }
    
}

struct PlayListView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        PlayListView()
            .environmentObject(spotify)
    }
}

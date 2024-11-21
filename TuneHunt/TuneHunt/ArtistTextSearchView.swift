import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct ArtistTextSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var searchText: String = ""
    @State var artistsPreview: [String] = []
    @State var artistSearchResults: [ArtistSearchResult] = []
    @State private var selectedSeparator = "Comma"
    @State private var searchCancellables: [AnyCancellable] = []
    @State private var alertItem: AlertItem? = nil
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    
    let separators = ["Comma", "Space", "Newline"]
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextEditor(text: $searchText)
                        .padding(.top,4)
                        .padding(.leading,4)
                        .frame(height: 200)
                } header: {
                    Text("Enter Artists Here:")
                }
                
                Section {
                    Picker("Separator", selection: $selectedSeparator) {
                        ForEach(separators, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                } header: {
                    Text("Select a seperator:")
                }
                .listRowBackground(Color.clear)
                
                Section {
                    if searchText.isEmpty {
                        Text("No artists found.")
                    } else {
                        ForEach(artistsPreview, id: \.self) { artist in
                            HStack {
                                Text(artist)
                                Button(action: { removeArtist(artist) }) {
                                    Image(systemName: "minus.circle")
                                }
                            }
                            .padding(.vertical, 2)
                            .padding(.horizontal, 8)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(5)
                            
                        }
                        .onChange(of: searchText, initial: true) {
                            splitArtists()
                        }
                        .onChange(of: selectedSeparator, initial: true) {
                            splitArtists()
                        }
                    }
                } header: {
                    Text("Result:")
                }
                
                Section {
                    Button {
                        selection = 1
                        searchArtists()
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Search artists in Spotify")
                            
                        }
                        
                    }
                    .foregroundStyle(textColor)
                    .padding()
                    .background(.green)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)
                
            }
            .padding()
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Enter artists")
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .ignoresSafeArea())
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message)
        }

    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistSearchResultsListView(artistsSearchResults: artistSearchResults)
        default:
            EmptyView()
        }
    }
    
    private func splitArtists() -> Void {
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
        artistsPreview = searchText
            .split(separator: separator)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removingDuplicates()
    }
    
    private func removeArtist(_ artist: String) {
        artistsPreview.removeAll { $0 == artist }
    }
    
    func searchArtists() {
        self.artistSearchResults = []
        let artistNames = artistsPreview
        guard !artistNames.isEmpty else {
            self.alertItem = AlertItem(
                title: "Couldn't Perform Search",
                message: "No artists where found."
            )
            return
        }
        
        var remainingSearches = artistNames.count
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
                            self.artistSearchResults.append(ArtistSearchResult(artist: artist))
                        }
                    }
                )
            self.searchCancellables.append(cancellable)
        }
    }
}

struct ArtistTextSearchView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        ArtistTextSearchView()
            .environmentObject(spotify)
    }
}

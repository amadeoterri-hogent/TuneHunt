import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct ArtistMultipleSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var searchText: String = ""
    @State private var artistsSearch: String = ""
    @State var artists: [String] = []
    @State var artistSearchResults: [ArtistSearchResult] = []
    @State private var selectedSeparator = "Auto"
    @State private var searchCancellables: [AnyCancellable] = []
    @State private var alertItem: AlertItem? = nil
    @State private var shouldNavigate = false
    @State private var searching: Bool = false
        
    let separators = ["Auto","Comma", "Space", "Newline"]
    let pasteboard = UIPasteboard.general
    
    var body: some View {
        ZStack {
            VStack {
                Form {
                    Section {
                        VStack {
                            TextEditor(text: $searchText)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .frame(height: 200)
                                .onChange(of: searchText, initial: true) {
                                    splitArtists()
                                }
                            
                            HStack {
                                Button {
                                } label: {
                                    Image(systemName: "list.clipboard")
                                }
                                .foregroundStyle(Theme(colorScheme).textColor)
                                .onTapGesture {
                                    if let textFromPasteboard = pasteboard.string {
                                        searchText.append(textFromPasteboard)
                                    }
                                }
                                
                                Spacer()
                                                    
                                Button {
                                } label: {
                                    Image(systemName: "clear")
                                }
                                .foregroundStyle(Theme(colorScheme).textColor)
                                .onTapGesture {
                                    print("Text cleared")
                                    searchText = ""
                                    artistsSearch = ""
                                    artists = []
                                }
                            }
                        }
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
                        .onChange(of: selectedSeparator, initial: true) {
                            splitArtists()
                        }

                    } header: {
                        Text("Select a seperator:")
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        Button {
                            searchArtists()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search artists in Spotify")
                            }
                        }
                        .foregroundStyle(Theme(colorScheme).textColor)
                        .padding()
                        .background(.green)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .disabled(artists.isEmpty)
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        if artists.isEmpty {
                            Text("No artists added.")
                        } else {
                            List {
                                ForEach(artists, id: \.self) {
                                    Text("\($0)")
                                }
                                .onDelete(perform: removeArtist)
                            }
                        }
                    } header: {
                        Text("Result:")
                    }
                    
                }
                .padding()
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Enter artists")
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .navigationDestination(isPresented: $shouldNavigate) {
                ArtistSearchResultsListView(artistsSearchResults: artistSearchResults)
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            
            if searching {
                ProgressView("Searching...", value: Double(artistSearchResults.count), total: Double(artists.count))
                    .progressViewStyle(.circular)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
    
    private func splitArtists() -> Void {
        let separator: Character
        artistsSearch = searchText
        switch selectedSeparator {
        case "Auto":
            artistsSearch = artistsSearch
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
        artists = artistsSearch
            .split(separator: separator)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removingDuplicates()
    }
    
    private func removeArtist(at offsets: IndexSet) {
        withAnimation {
            artists.remove(atOffsets: offsets)
        }
    }
    
    func searchArtists() {
        self.artistSearchResults = []
        let artistNames = artists
        guard !artistNames.isEmpty else {
            self.alertItem = AlertItem(
                title: "Couldn't Perform Search",
                message: "No artists where found."
            )
            return
        }
        
        searching = true
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
                            self.searching = false
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
                            // Check for duplicates after search
                            if !self.artistSearchResults.contains(where: { $0.artist.id == artist.id }) {
                                self.artistSearchResults.append(ArtistSearchResult(artist: artist))
                            }
                        }
                    }
                )
            self.searchCancellables.append(cancellable)
        }
    }
}

#Preview {
     let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    ArtistMultipleSearchView()
        .environmentObject(spotify)
}
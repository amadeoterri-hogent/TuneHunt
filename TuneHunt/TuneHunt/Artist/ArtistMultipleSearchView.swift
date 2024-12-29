import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct ArtistMultipleSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @FocusState private var searchTextIsFocused: Bool
    
    @State private var artistsSearch = ""
    @State private var selectedSeparator = "Auto"
    @State private var searchCancellables: [AnyCancellable] = []
    @State private var alertItem: AlertItem? = nil
    @State private var shouldNavigate = false
    @State private var isSearching = false
    @State private var showPreview = false
    
    let separators = ["Auto","Comma", "Space", "Newline"]
    let pasteboard = UIPasteboard.general
    
    @State var searchText: String = ""
    @State var artists: [String] = []
    @State var artistSearchResults: [ArtistSearchResult] = []
    
    var body: some View {
        ZStack {
            ScrollView {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            searchTextIsFocused = false
                        }
                    VStack {
                        DefaultNavigationTitleView(titleText: "Enter artists")
                        btnSearchSpotify
                        txtEditor
                    }
                }
            }
            .toolbar {
                toolBar
            }
            .padding()
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $shouldNavigate) {
                ArtistSearchResultsListView(artistsSearchResults: artistSearchResults)
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .sheet(isPresented: $showPreview) {
                ArtistPreviewView(artists: $artists)
            }
                       
            if isSearching {
                DefaultProgressView(progressViewText: "Searching...")
            }
        }
    }
    
    var btnSearchSpotify: some View {
        Button {
            searchArtists()
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search artists in Spotify")
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
    }
    
    var txtEditor: some View {
        TextEditor(text: $searchText)
            .contentMargins(12)
            .focused($searchTextIsFocused)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .frame(height: 480)
            .cornerRadius(12)
            .onChange(of: searchText, initial: true) {
                splitArtists()
            }
            .padding(.top, 24)
    }
    
    /// Toolbar: Start
    var toolBar: some View {
        Menu {
            btnToolBarPreview
            btnToolBarPasteFromClipboard
            btnToolBarClearText
        }
        label: {
            Image(systemName: "ellipsis.circle")
        }
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    var btnToolBarPreview: some View {
        Button {
            showPreview = true
        } label: {
            HStack {
                Image(systemName: "eye")
                Text("Preview")
            }
        }
    }
    
    var btnToolBarPasteFromClipboard: some View {
        Button {
            if let textFromPasteboard = pasteboard.string {
                searchText.append(textFromPasteboard)
            }
        } label: {
            HStack {
                Image(systemName: "list.clipboard")
                Text("Paste from clipboard")
            }
        }
    }
    
    var btnToolBarClearText: some View {
        Button {
            searchText = ""
            artistsSearch = ""
            artists = []
        } label: {
            HStack {
                Image(systemName: "clear")
                Text("Clear text")
            }
        }
    }
    
    var pkrToolBarArtistsSeparator: some View {
        Picker("Separator", selection: $selectedSeparator) {
            ForEach(separators, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: selectedSeparator, initial: false) {
            splitArtists()
        }
    }
    /// Toolbar: End
    
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
        
        self.isSearching = true
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
    let spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    ArtistMultipleSearchView()
        .environmentObject(spotify)
}



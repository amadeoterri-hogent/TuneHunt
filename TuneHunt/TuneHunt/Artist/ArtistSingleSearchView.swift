import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistSingleSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var nameArtist = ""
    @State private var alertItem: AlertItem? = nil
    @State private var searchCancellable: AnyCancellable? = nil
    @State private var isSearching = false
    @State private var shouldNavigate = false
    @State private var spotifyArtists: [Artist] = []
    
    @State var artists: [Artist] = []
    
    var body: some View {
        ZStack {
            artistSingleSearchView
            
            if isSearching {
                ProgressView("Searching artists...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    var artistSingleSearchView: some View {
        VStack {
            txtNavigationTitle
            searchBar
            captionArtist
            
            if artists.isEmpty && !isSearching {
                txtNoResults
            }
            else {
                lstArtists
            }
            Spacer()
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
        .navigationDestination(isPresented: $shouldNavigate) {
            if !spotifyArtists.isEmpty {
                PlaylistSelectView(artists: $spotifyArtists)
            }
        }
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message)
        }
    }
    
    var txtNavigationTitle: some View {
        Text("Search For Artist")
            .font(.largeTitle)
            .bold()
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var searchBar: some View {
        HStack {
            TextField("Search artist in spotify...", text: $nameArtist, onCommit: searchArtist)
                .padding(.leading, 36)
                .submitLabel(.search)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
                .overlay(
                    searchBarOverlay
                )
        }
        .padding(.horizontal)
    }
    
    var searchBarOverlay: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Spacer()
            if !nameArtist.isEmpty {
                btnClearSearch
            }
        }
        .padding()
    }
        
    var btnClearSearch: some View {
        Button(action: {
            self.nameArtist = ""
            self.artists = []
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        })
    }
    
    var captionArtist: some View {
        Text("Tap an artist to proceed")
            .font(.caption2)
            .opacity(0.4)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var txtNoResults: some View {
        Text("No results")
            .frame(maxHeight: .infinity, alignment: .center)
            .foregroundColor(Theme(colorScheme).textColor)
            .font(.title)
            .opacity(0.4)
            .padding(.bottom, 48)
    }
    
    var lstArtists: some View {
        List {
            ForEach(artists, id: \.self) { artist in
                Button {
                    spotifyArtists = [artist]
                    shouldNavigate = true
                } label: {
                    Text("\(artist.name)")
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .padding()
    }
    
    func searchArtist() {
        if !validate() {
            return
        }
        
        self.artists = []
        self.isSearching = true
        
        self.searchCancellable = spotify.api.search(
            query: self.nameArtist, categories: [.artist]
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
            },
            receiveValue: { searchResults in
                self.artists = searchResults.artists?.items ?? []
            }
        )
    }
    
    func validate() -> Bool {
        if self.nameArtist == "" {
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

#Preview{
    let spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
//    let artists: [Artist] = [
//        .pinkFloyd,.radiohead
//    ]
    
    let artists: [Artist] = []
    
    ArtistSingleSearchView(artists:artists)
        .environmentObject(spotify)
}

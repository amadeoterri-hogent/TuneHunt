import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistSingleSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State var artists: [Artist] = []
    @State private var nameArtist: String = ""
    @State private var alertItem: AlertItem? = nil
    @State private var searchCancellable: AnyCancellable? = nil
    @State private var isSearching = false
    @State private var shouldNavigate = false
    @State private var spotifyArtists: [Artist] = []
    
    var body: some View {
        ZStack {
            VStack {
                Text("Search For Artist")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("Search artist in spotify",text: $nameArtist,onCommit:searchArtist)
                        .padding(.leading, 28)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                Spacer()
                                if !nameArtist.isEmpty {
                                    Button(action: {
                                        self.nameArtist = ""
                                        self.artists = []
                                    }, label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    })
                                }
                            }
                        )
                        .submitLabel(.search)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 8)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Text("Tap an artist to proceed")
                    .font(.caption2)
                    .foregroundColor(Theme(colorScheme).textColor)
                    .opacity(0.4)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if artists.isEmpty && !isSearching {
                    Text("No results")
                        .frame(maxHeight: .infinity, alignment: .center)
                        .foregroundColor(Theme(colorScheme).textColor)
                        .font(.title)
                        .opacity(0.6)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 48)
                }
                else {
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
            
            if isSearching {
                ProgressView("Searching artists...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    func searchArtist() {
        if self.nameArtist == "" {
            self.alertItem = AlertItem(
                title: "Couldn't search artist",
                message: "Artist name is empty."
            )
            return
        }
        
        guard spotify.currentUser?.uri != nil else {
            self.alertItem = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
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
}

#Preview{
    let spotify: Spotify = {
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

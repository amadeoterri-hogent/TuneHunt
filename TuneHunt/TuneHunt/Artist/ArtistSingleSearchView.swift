import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistSingleSearchView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme

    @State var artists: [Artist] = []
    @State private var nameArtist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var alertItem: AlertItem? = nil
    @State private var searchCancellable: AnyCancellable? = nil
    @State private var isSearching = false
    @State private var shouldNavigate = false
    @State private var spotifyArtists: [Artist] = []

    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Enter artist name...",text: $nameArtist)
                }

                Section {
                    VStack {
                        Button {
                            searchArtist()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search artist in Spotify")
                            }
                        }
                        .foregroundStyle(Theme(colorScheme).textColor)
                        .padding()
                        .background(.green)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        Text("Tap an artist to proceed.")
                            .font(.caption)
                            .foregroundColor(Theme(colorScheme).textColor)
                            .opacity(0.4)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .listRowBackground(Color.clear)
                
                Section {
                    if artists.isEmpty {
                        if isSearching {
                            ProgressView("Searching artists...")
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                        else {
                            Text("No results")
                                .foregroundColor(Theme(colorScheme).textColor)
                        }
                    }
                    else {
                        List {
                            ForEach(artists, id: \.self) { artist in
                                Button {
                                    spotifyArtists.append(artist)
                                    shouldNavigate = true
                                } label: {
                                    Text("\(artist.name)")
                                }
                            }
                        }
                    }
                }
                header: {
                    Text("Result:")
                }
            }
            .scrollContentBackground(.hidden)
            
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
        .navigationDestination(isPresented: $shouldNavigate) {
        PlaylistSelectView(spotify: spotify, artists: spotifyArtists)
        }
    }
    
    func searchArtist() {
        
        if self.nameArtist == "" {
            self.alert = AlertItem(
                title: "Couldn't search artist",
                message: "Artist name is empty."
            )
        }
        
        guard let userURI = spotify.currentUser?.uri else {
            self.alert = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return
        }
        
        self.artists = []
        
        if self.nameArtist.isEmpty { return }

        print("searching with query '\(self.nameArtist)'")
        self.isSearching = true
        
        self.searchCancellable = spotify.api.search(
            query: self.nameArtist, categories: [.artist]
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                self.isSearching = false
                if case .failure(let error) = completion {
                    self.alert = AlertItem(
                        title: "Couldn't Perform Search",
                        message: error.localizedDescription
                    )
                }
            },
            receiveValue: { searchResults in
                self.artists = searchResults.artists?.items ?? []
                print("received \(self.artists.count) artists")
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
        
    return ArtistSingleSearchView(spotify: spotify)
}

import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistSearchArtistsView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var isSearchingPlaylists = false
    @State private var isSearchingArtists = false
    @State private var namePlaylist: String = ""
    @State private var shouldNavigate = false
    @State var artistsSearchResults: [ArtistSearchResult] = []
    @State private var alert: AlertItem? = nil
    @State private var searchCancellable: AnyCancellable? = nil
    @State private var artistsCancellables: Set<AnyCancellable> = []
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    
    var body: some View {
        ZStack {
            VStack {
                Form {
                    Section {
                        TextField("Enter playlist name...",text: $namePlaylist)
                    }
                    
                    Section {
                        VStack {
                            Button {
                                isSearchingPlaylists = true
                                searchPlaylist()
                            } label: {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search playlists in Spotify")
                                }
                            }
                            .foregroundStyle(Theme(colorScheme).textColor)
                            .padding()
                            .background(.green)
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, alignment: .center)
                            
                            Text("Tap a playlist to proceed.")
                                .font(.caption)
                                .foregroundColor(Theme(colorScheme).textColor)
                                .opacity(0.4)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowBackground(Color.clear)
                    
                    Section {
                        if playlists.isEmpty {
                            if isSearchingPlaylists {
                                ProgressView("Searching playlists...")
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                            else {
                                Text("No results")
                                    .foregroundColor(Theme(colorScheme).textColor)
                            }
                        }
                        else {
                            List {
                                ForEach(playlists, id: \.self) { playlist in
                                    Button {
                                        self.isSearchingArtists = true
                                        findArtists(playlist:playlist)
                                    } label: {
                                        Text("\(playlist.name)")
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
                ArtistSearchResultsListView(artistsSearchResults: artistsSearchResults)
            }
            
            if isSearchingArtists {
                ProgressView("Searching artists...")
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    func searchPlaylist() {
        if self.namePlaylist == "" {
            self.alert = AlertItem(
                title: "Couldn't search artist",
                message: "Artist name is empty."
            )
        }
        
        guard spotify.currentUser?.uri != nil else {
            self.alert = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return
        }
        
        self.playlists = []
        self.isSearchingPlaylists = true
        
        self.searchCancellable = spotify.api.search(
            query: self.namePlaylist, categories: [.playlist]
        )
        .receive(on: RunLoop.main)
        .sink(
            receiveCompletion: { completion in
                self.isSearchingPlaylists = false
                if case .failure(let error) = completion {
                    self.alert = AlertItem(
                        title: "Couldn't Perform Search",
                        message: error.localizedDescription
                    )
                }
            },
            receiveValue: { searchResults in
                self.playlists = searchResults.playlists?.items ?? []
                print("Received \(self.playlists.count) playlists")
            }
        )
    }
    
    func findArtists(playlist: Playlist<PlaylistItemsReference>) {
        self.loadPlaylistCancellable =  spotify.api.playlistItems(playlist.uri)
            .extendPagesConcurrently(self.spotify.api)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion:{ _ in },
                receiveValue: self.addArtistsFromPlaylist(page:)
            )
    }
    
    
    func addArtistsFromPlaylist(page: PlaylistItems) {
        let playlistItems = page.items.map(\.item)
        var remainingRequests = playlistItems.count
        
        for playlistItem in playlistItems {
            
            guard let playlistItem = playlistItem else {
                continue
            }
            
            if case .track(let track) = playlistItem {
                for artist in track.artists! {
                    if !self.artistsSearchResults.contains(where: { $0.artist.id == artist.id }) {
                        if let uri = artist.uri {
                            spotify.api.artist(uri)
                                .receive(on: RunLoop.main)
                                .sink(
                                    receiveCompletion: { completion in
                                        if case .failure(let error) = completion {
                                            self.alert = AlertItem(
                                                title: "Couldn't Perform Search",
                                                message: error.localizedDescription
                                            )
                                        }  
                                    },
                                    receiveValue: { artist in
                                        self.artistsSearchResults.append(ArtistSearchResult(artist: artist))
                                    }
                                )
                                .store(in: &artistsCancellables)
                        }
                    }
                }
            }
        }
        
        self.isSearchingArtists = false
        self.shouldNavigate = true
    }
}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    PlaylistSearchArtistsView()
        .environmentObject(spotify)
    
}

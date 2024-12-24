import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistSearchArtistsView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var isSearching = false
    @State private var namePlaylist: String = ""
    @State private var shouldNavigate = false
    @State var artistsSearchResults: [ArtistSearchResult] = []
    @State private var alertItem: AlertItem? = nil
    @State private var searchCancellable: AnyCancellable? = nil
    @State private var artistsCancellables: Set<AnyCancellable> = []
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    
    var body: some View {
        ZStack {
            VStack {
                Text("Search For Playlist")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    TextField("Search playlist in spotify...",text: $namePlaylist, onCommit: searchPlaylist)
                        .padding(.leading, 28)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.secondary)
                                Spacer()
                                if !namePlaylist.isEmpty {
                                    Button(action: {
                                        self.namePlaylist = ""
                                        self.playlists = []
                                    }, label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.secondary)
                                    })
                                }
                            }
                        )
                        .submitLabel(.search)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                
                Text("Tap a playlist to proceed")
                    .font(.caption2)
                    .foregroundColor(Theme(colorScheme).textColor)
                    .opacity(0.4)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                if playlists.isEmpty && !isSearching {
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
                        ForEach(playlists, id: \.self) { playlist in
                            Button {
                                findArtists(playlist:playlist)
                            } label: {
                                Text("\(playlist.name)")
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                    .padding()
                }
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .foregroundStyle(Theme(colorScheme).textColor)
            .navigationDestination(isPresented: $shouldNavigate) {
                if !artistsSearchResults.isEmpty {
                    ArtistSearchResultsListView(artistsSearchResults: artistsSearchResults)
                }
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            
            if isSearching {
                ProgressView("Searching...")
                    .progressViewStyle(.circular)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
    
    func searchPlaylist() {
        if self.namePlaylist == "" {
            self.alertItem = AlertItem(
                title: "Couldn't search artist",
                message: "Artist name is empty."
            )
        }
        
        guard spotify.currentUser?.uri != nil else {
            self.alertItem = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return
        }
        
        self.playlists = []
        self.isSearching = true
        
        self.searchCancellable = spotify.api.search(
            query: self.namePlaylist, categories: [.playlist]
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
                self.playlists = searchResults.playlists?.items ?? []
                print("Received \(self.playlists.count) playlists")
            }
        )
    }
    
    func findArtists(playlist: Playlist<PlaylistItemsReference>) {
        self.isSearching = true
        self.loadPlaylistCancellable =  spotify.api.playlistItems(playlist.uri)
            .extendPagesConcurrently(self.spotify.api)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion:{ _ in },
                receiveValue: self.addArtistsFromPlaylist(page:)
            )
    }
    
    func addArtistsFromPlaylist(page: PlaylistItems) {
        let playlistItems = page.items.compactMap(\.item)
        var remainingRequests = 0

        for playlistItem in playlistItems {
            guard case .track(let track) = playlistItem else { continue }
            
            for artist in track.artists ?? [] {
                guard let uri = artist.uri,
                      !self.artistsSearchResults.contains(where: { $0.artist.id == artist.id }) else { continue }
                
                remainingRequests += 1

                spotify.api.artist(uri)
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.alertItem = AlertItem(
                                    title: "Couldn't Perform Search",
                                    message: error.localizedDescription
                                )
                            }
                            self.decrementRemainingRequests(&remainingRequests)
                        },
                        receiveValue: { artist in
                            if !self.artistsSearchResults.contains(where: { $0.artist.id == artist.id }) {
                                self.artistsSearchResults.append(ArtistSearchResult(artist: artist))
                            }
                        }
                    )
                    .store(in: &artistsCancellables)
            }
        }

        // If no requests were made, mark as done immediately
        if remainingRequests == 0 {
            self.isSearching = false
            self.shouldNavigate = true
        }
    }

    private func decrementRemainingRequests(_ remainingRequests: inout Int) {
        remainingRequests -= 1
        if remainingRequests == 0 {
            self.isSearching = false
            self.shouldNavigate = true
        }
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

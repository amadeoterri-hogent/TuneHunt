import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistSearchArtistsView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var isSearching = false
    @State private var namePlaylist = ""
    @State private var shouldNavigate = false
    @State private var alertItem: AlertItem? = nil
    @State private var searchCancellable: AnyCancellable? = nil
    @State private var artistsCancellables: Set<AnyCancellable> = []
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    
    @State var artistsSearchResults: [ArtistSearchResult] = []
    
    var body: some View {
        ZStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Search For Playlist")
                txtSearchPlaylist
                DefaultCaption(captionText: "Tap a playlist to proceed")
                playlistSearchResults
            }
            .padding()
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
                DefaultProgressView(progressViewText: "Searching...")
            }
        }
    }
    
    var txtSearchPlaylist: some View {
        TextField("Search playlist in spotify...", text: $namePlaylist, onCommit: searchPlaylist)
            .padding(.leading, 28)
            .submitLabel(.search)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(overlaySearchPlaylist)
    }
    
    var overlaySearchPlaylist: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Spacer()
            if !namePlaylist.isEmpty {
                btnClearText
            }
        }
        .padding()
    }
    
    var btnClearText: some View {
        Button(action: {
            self.namePlaylist = ""
            self.playlists = []
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        })
    }
    
    var playlistSearchResults: some View {
        Group {
            if playlists.isEmpty {
                DefaultNoResults()
            }
            else {
                lstPlaylists
            }
        }
    }
    
    var lstPlaylists: some View {
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
                            remainingRequests -= 1
                            if remainingRequests == 0 {
                                self.isSearching = false
                                self.shouldNavigate = true
                            }
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

        if remainingRequests == 0 {
            self.isSearching = false
            self.shouldNavigate = true
        }
    }
}

#Preview {
    let spotify = {
        let spotify = Spotify.shared
        spotify.isAuthorized = true
        return spotify
    }()
    
    PlaylistSearchArtistsView()
        .environmentObject(spotify)
    
}

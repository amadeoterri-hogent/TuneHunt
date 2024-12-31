import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import SpotifyExampleContent


struct PlaylistSelectView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
//    @Binding var artists: [Artist]
    var artists: [Artist]
    
    @State private var alertItem: AlertItem? = nil
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var searchCancellables: Set<AnyCancellable> = []
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    @State private var isLoading = false
    @State private var isSearchingTracks = false
    @State private var showingAlert = false
    @State private var shouldNavigate: Bool = false
    @State private var showCreatePlaylist: Bool = false
    @State private var selectedPlaylist: Playlist<PlaylistItems>? = nil
    
    @State var playlists: [Playlist<PlaylistItemsReference>] = []
    @State var tracks: [Track] = []
    
    var topTracks = UserDefaults.standard.integer(forKey: "topTracks")
    var selectedCountryCode: String = UserDefaults.standard.string(forKey: "Country") ?? "BE"
    var isPreview = false
    
    var body: some View {
        ZStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Select a Playlist")
                playlistView
            }
            .padding()
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .foregroundStyle(Theme(colorScheme).textColor)
            .navigationDestination(isPresented: $shouldNavigate) {
                if let playlist = selectedPlaylist {
                    FinishView(tracks: tracks, playlist: playlist, artists: artists)
                }
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .toolbar {
                toolBarPlaylist
            }
            .onAppear(perform: retrievePlaylists)
            
            if isLoading {
                DefaultProgressView(progressViewText: "Loading...")
            }
            
            if isSearchingTracks {
                DefaultProgressView(progressViewText: "Searching tracks...")
            }
        }
    }
    
    var playlistView: some View {
        Group {
            if !playlists.isEmpty {
                DefaultCaption(captionText: "Tap a playlist to proceed")
                    .padding(.top, 8)
                lstPlaylists
            }
            else {
                DefaultNoResults()
            }
        }
    }
    
    var lstPlaylists: some View {
        List {
            ForEach(playlists, id: \.uri) { playlist in
                PlaylistCellView(playlist: playlist, loadPlaylist: { playlist in
                    loadPlaylist(selectedPlaylist: playlist)
                })
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
    
    var toolBarPlaylist: some View {
        Button {
            showCreatePlaylist = true
        } label: {
            Image(systemName: "plus" )
                .font(.title2)
                .frame(width:48, height: 48)
                .foregroundStyle(Theme(colorScheme).textColor)
        }
        .sheet(isPresented: $showCreatePlaylist) {
            PlaylistCreateView(onPlaylistCreated: { newPlaylist in
                playlists.insert(newPlaylist, at: 0)
            })
        }
    }
    
    func retrievePlaylists() {
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }

        self.isLoading = true
        self.playlists = []
        
        spotify.api.currentUserPlaylists(limit: 50)
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.alertItem = AlertItem(
                            title: "Couldn't Perform Search",
                            message: error.localizedDescription
                        )
                    }
                    self.isLoading = false
                },
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items
                    self.playlists.append(contentsOf: playlists)
                }
            )
            .store(in: &cancellables)
    }
    
    func loadPlaylist(selectedPlaylist: Playlist<PlaylistItemsReference>) {
        self.isSearchingTracks = true
        self.loadPlaylistCancellable =  spotify.api.playlist(selectedPlaylist)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion:{ _ in
                    searchTopTracks()
                },
                receiveValue: { playlist in
                    self.selectedPlaylist = playlist
                }
            )
    }
    
    func searchTopTracks() {
        if isPreview {
            return
        }
        self.tracks = []
        var remainingRequests = artists.count
        
        for artist in artists {
            if let uri = artist.uri {
                spotify.api.artistTopTracks(uri, country: selectedCountryCode)
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
                                self.tracks = self.tracks.removingDuplicates()
                                self.isSearchingTracks = false
                                self.shouldNavigate = true
                            }
                        },
                        receiveValue: { searchResults in
                            let topTracks = searchResults.prefix(topTracks)
                            for track in topTracks {
                                if !self.tracks.contains(where: { $0.id == track.id }) {
                                    self.tracks.append(track)
                                }
                            }
                        }
                    )
                    .store(in: &searchCancellables)
            } else {
                // Handle artists without a URI (optional improvement)
                remainingRequests -= 1
                if remainingRequests == 0 {
                    self.tracks = self.tracks.removingDuplicates()
                    self.isSearchingTracks = false
                    self.shouldNavigate = true
                }
            }
        }
    }
}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify.shared
        spotify.isAuthorized = true
        return spotify
    }()
    
    let playlists: [Playlist<PlaylistItemsReference>] = [
        .menITrust, .modernPsychedelia,
        .lucyInTheSkyWithDiamonds, .rockClassics,
        .thisIsMFDoom, .thisIsSonicYouth, .thisIsMildHighClub,
        .thisIsSkinshape
    ]
    
//    let playlists: [Playlist<PlaylistItemsReference>] = []

    let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
//    PlaylistSelectView(artists: .constant(artists), playlists: playlists)
//        .environmentObject(spotify)
    PlaylistSelectView(artists: artists, playlists: playlists)
        .environmentObject(spotify)
}

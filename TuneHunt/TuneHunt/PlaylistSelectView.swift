import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import SpotifyExampleContent


struct PlaylistSelectView: View {
    @ObservedObject var spotify: Spotify

    @Environment(\.colorScheme) var colorScheme
    
    @State private var alert: AlertItem? = nil
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    @State private var showingAlert = false
    @State private var shouldNavigate: Bool = false
    @State private var shouldCreatePlaylist: Bool = false
    @State private var selectedPlaylist: Playlist<PlaylistItems>? = nil
    
    @State var artists: [Artist] = []
    
    init(spotify: Spotify, artists: [Artist]) {
        self.artists = artists
        self.spotify = spotify
    }
    
    /// Used only by the preview provider to provide sample data.
    fileprivate init(spotify: Spotify,samplePlaylists: [Playlist<PlaylistItemsReference>], sampleArtists: [Artist]) {
        self._playlists = State(initialValue: samplePlaylists)
        self.artists = sampleArtists
        self.spotify = spotify
    }
    
    var body: some View {
        VStack {
            Text(
                """
                Select a playlist to add the tracks or
                create a new playlist
                """
            )
            .font(.caption)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
            .padding(.horizontal, 24)

            List {
                ForEach(playlists, id: \.uri) { playlist in
                    PlaylistCellView(spotify: spotify, shouldNavigate: $shouldNavigate, selectedPlaylist: $selectedPlaylist, playlist: playlist)
                }
            }
            .scrollContentBackground(.hidden)
            
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
        .navigationDestination(isPresented: $shouldNavigate) {
            if let playlist = selectedPlaylist {
                FinishView(spotify:spotify, playlist: playlist, artists: artists)
            } else {
                EmptyView()
            }
        }
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .navigationTitle("Your Playlists")
        .toolbar {
            Button {
                shouldCreatePlaylist = true
            } label: {
                Image(systemName: "plus" )
                    .font(.title2)
                    .frame(width:48,height: 48)
                    .foregroundStyle(Theme(colorScheme).textColor)
            }
            .sheet(isPresented: $shouldCreatePlaylist) {
                PlaylistCreateView(spotify: spotify)
            }
        }
        .onAppear(perform: retrievePlaylists)
    }
    
    
    func retrievePlaylists() {
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }
        print("Retrieving playlists")

        self.isLoadingPlaylists = true
        self.playlists = []
        
        spotify.api.currentUserPlaylists(limit: 50)
        // Gets all pages of playlists.
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingPlaylists = false
                    switch completion {
                    case .finished:
                        self.couldntLoadPlaylists = false
                    case .failure(let error):
                        self.couldntLoadPlaylists = true
                        self.alert = AlertItem(
                            title: "Couldn't Retrieve Playlists",
                            message: error.localizedDescription
                        )
                    }
                },
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items
                    self.playlists.append(contentsOf: playlists)
                }
            )
            .store(in: &cancellables)
    }
}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    let playlists: [Playlist<PlaylistItemsReference>] = [
        .menITrust, .modernPsychedelia,
        .lucyInTheSkyWithDiamonds, .rockClassics,
        .thisIsMFDoom, .thisIsSonicYouth, .thisIsMildHighClub,
        .thisIsSkinshape
    ]
    
    let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
    return PlaylistSelectView(spotify: spotify, samplePlaylists: playlists, sampleArtists: artists)
    
}

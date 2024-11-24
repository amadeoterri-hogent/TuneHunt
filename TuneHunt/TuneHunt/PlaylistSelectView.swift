import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import SpotifyExampleContent


struct PlaylistSelectView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var alert: AlertItem? = nil
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    @State var artists: [Artist]
    @State private var showingAlert = false
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    init(artists: [Artist]) {
        self.artists = artists
    }
    
    /// Used only by the preview provider to provide sample data.
    fileprivate init(samplePlaylists: [Playlist<PlaylistItemsReference>], sampleArtists: [Artist]) {
        self._playlists = State(initialValue: samplePlaylists)
        self._artists = State(initialValue: sampleArtists)
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
            .padding()

            List {
                ForEach(playlists, id: \.uri) { playlist in
                    PlaylistCellView(spotify: spotify, playlist: playlist,artists: artists)
                }
            }
            .scrollContentBackground(.hidden)
            
        }
        .background(
            LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .foregroundStyle(textColor)
        .navigationDestination(isPresented: $shouldNavigate) {
            destinationView()
        }
        .onAppear(perform: retrievePlaylists)
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .navigationTitle("Your Playlists")
        .toolbar {
            Button {
                selection = 1
                shouldNavigate = true
            } label: {
                Image(systemName: "plus" )
                    .font(.title2)
                    .frame(width:48,height: 48)
                    .foregroundStyle(textColor)
            }
            .sheet(isPresented: $shouldNavigate) {
                destinationView()
            }
        }
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            PlaylistCreateView(artists: artists)
        default:
            EmptyView()
        }
    }
    
    
    func retrievePlaylists() {
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }
        
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

struct PlayListSelectView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static let playlists: [Playlist<PlaylistItemsReference>] = [
        .menITrust, .modernPsychedelia,
        .lucyInTheSkyWithDiamonds, .rockClassics,
        .thisIsMFDoom, .thisIsSonicYouth, .thisIsMildHighClub,
        .thisIsSkinshape
    ]
    
    static let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
    static var previews: some View {
        PlaylistSelectView(samplePlaylists: playlists, sampleArtists: artists)
            .environmentObject(spotify)
    }
}

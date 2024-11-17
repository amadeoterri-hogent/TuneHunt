import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistSelectView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var alert: AlertItem? = nil
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    @State private var selectedArtists: [Artist]   
    @State private var showingAlert = false
    @State private var selectedPlaylist: Playlist<PlaylistItems>? = nil
    @State private var selection: Int? = nil
    @State private var shouldNavigate = false
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    init(artists:[Artist]) {
        self.selectedArtists = artists
    }
    
    var body: some View {
        // TODO: on select playlist show finish screen
        VStack {
            List {
                ForEach(playlists, id: \.uri) { playlist in
                    Button {
                        selection = 1
                        loadPlaylist(playlist: playlist)
                        shouldNavigate = true
                    } label: {
                        Text("\( playlist.name)")
                    }
                }
            }
            .scrollContentBackground(.hidden)

        }
        .navigationDestination(isPresented: $shouldNavigate) {
            destinationView()
        }
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(textColor)
        .navigationTitle("Playlists")
        .onAppear(perform: retrievePlaylists)
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .padding()
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            if let playlist = selectedPlaylist {
                FinishView(playlist: playlist, artists: selectedArtists)
            } else {
                // TODO: Throw alert?
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
    
    func retrievePlaylists() {
        
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
    
    func loadPlaylist(playlist: Playlist<PlaylistItemsReference>) {
        self.loadPlaylistCancellable =  spotify.api.playlist(playlist)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion:{ _ in }
                , receiveValue: { playlist in
                    self.selectedPlaylist = playlist
                    
                }
            )
    }
}

//struct PlayListSelectView_Previews: PreviewProvider {
//    
//    static let spotify: Spotify = {
//        let spotify = Spotify()
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    static var previews: some View {
//        PlaylistSelectView()
//            .environmentObject(spotify)
//    }
//}

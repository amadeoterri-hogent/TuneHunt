import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import SpotifyExampleContent


struct PlaylistSelectView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    @Binding var artists: [Artist]
    
    @State var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var alertItem: AlertItem? = nil
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isLoadingPlaylists = false
    @State private var isLoading = false
    @State private var showingAlert = false
    @State private var shouldNavigate: Bool = false
    @State private var shouldCreatePlaylist: Bool = false
    @State private var selectedPlaylist: Playlist<PlaylistItems>? = nil

    
    var body: some View {
        ZStack {
            VStack {
                Text("Select a Playlist")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if !playlists.isEmpty {
                    Text("Tap a playlist to proceed")
                        .font(.caption2)
                        .foregroundColor(Theme(colorScheme).textColor)
                        .opacity(0.4)
                        .padding(.horizontal)
                        .padding(.top)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    List {
                        ForEach(playlists, id: \.uri) { playlist in
                            PlaylistCellView(isLoading: $isLoading, shouldNavigate: $shouldNavigate, selectedPlaylist: $selectedPlaylist, playlist: playlist)
                        }
                        .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
                else {
                    Text("No results")
                        .frame(maxHeight: .infinity, alignment: .center)
                        .foregroundColor(Theme(colorScheme).textColor)
                        .font(.title)
                        .opacity(0.6)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 48)
                }
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .foregroundStyle(Theme(colorScheme).textColor)
            .navigationDestination(isPresented: $shouldNavigate) {
                if let playlist = selectedPlaylist {
                    FinishView(playlist: playlist, artists: artists)
                }
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .toolbar {
                Button {
                    shouldCreatePlaylist = true
                } label: {
                    Image(systemName: "plus" )
                        .font(.title2)
                        .frame(width:48, height: 48)
                        .foregroundStyle(Theme(colorScheme).textColor)
                }
                .sheet(isPresented: $shouldCreatePlaylist) {
                    PlaylistCreateView(onPlaylistCreated: { newPlaylist in
                        playlists.insert(newPlaylist, at: 0)
                    })
                }
            }
            .onAppear(perform: retrievePlaylists)
            
            if isLoading || isLoadingPlaylists {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }
    
    
    func retrievePlaylists() {
        // Don't try to load any playlists if we're in preview mode.
        if ProcessInfo.processInfo.isPreviewing { return }

        self.isLoadingPlaylists = true
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
                    self.isLoadingPlaylists = false
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
    
//    let playlists: [Playlist<PlaylistItemsReference>] = []

    let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
    PlaylistSelectView(artists: .constant(artists), playlists: playlists)
        .environmentObject(spotify)
}

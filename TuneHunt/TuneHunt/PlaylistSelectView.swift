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
    
    @State private var showingAlert = false
    @State private var selectedPlaylist = ""
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    
    var body: some View {
        // TODO: on select playlist show finish screen
        VStack {
            List {
                ForEach(playlists, id: \.uri) { playlist in
                    Button {
                        selectedPlaylist = playlist.name
                        showingAlert = true
                    } label: {
                        Text("\( playlist.name)")
                    }
                    .alert("Playlist \(selectedPlaylist) selected", isPresented: $showingAlert) {
                        Button("OK", role: .cancel) { }
                    }
                }
            }
            .scrollContentBackground(.hidden)

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
}

struct PlayListSelectView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        PlaylistSelectView()
            .environmentObject(spotify)
    }
}

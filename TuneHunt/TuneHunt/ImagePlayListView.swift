import SwiftUI
import Combine
import SpotifyWebAPI

struct ImagePlayListView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false


    var body: some View {
        VStack {
            TextField("Enter playlist...",text: $namePlaylist)
            Button(action: createPlaylist, label: {
                Text("Create Playlist")
            })
            .frame(maxWidth: .infinity,alignment: .leading)
            .buttonStyle(.bordered)
            .navigationTitle("Create playlist")

            Text("Select playlist")
            List {
                ForEach(playlists, id: \.uri) { playlist in
                    Text("\( playlist.name)")
                }
            }
            Spacer()
        }
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .padding()
        .onAppear(perform: retrievePlaylists)

        

    }
    
    func retrievePlaylists() {
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
    
    func createPlaylist() {
        
        if self.namePlaylist == "" {
            self.alert = AlertItem(
                title: "Couldn't create playlist Search",
                message: "Playlist name is empty."
            )
        }
        guard let userURI = spotify.currentUser?.uri else {
            self.alert = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return
        }
        
        let playlistDetails = PlaylistDetails(
            name: self.namePlaylist,
            isPublic: true,
            isCollaborative: false
        )
        
        
        // Create the playlist and assign to cancellable
        createPlaylistCancellable = spotify.api.createPlaylist(for: userURI, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Playlist created successfully.")
                    case .failure(let error):
                        print("Failed to create playlist: \(error)")
                        self.alert = AlertItem(
                            title: "Failed to create playlist",
                            message: "There went something wrong while creating a playlist."
                        )
                    }
                },
                receiveValue: { playlist in
                    print("Created playlist:", playlist)
                }
            )
    }
}

struct ImagePlayListView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        ImagePlayListView()
            .environmentObject(spotify)
    }
}

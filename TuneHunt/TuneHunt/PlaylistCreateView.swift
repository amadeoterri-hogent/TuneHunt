import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistCreateView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    
    var body: some View {
        // TODO: styling
        TextField("Enter playlist...",text: $namePlaylist)
        Button(action: createPlaylist, label: {
            Text("Create Playlist")
        })
        .frame(maxWidth: .infinity,alignment: .leading)
        .buttonStyle(.bordered)
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


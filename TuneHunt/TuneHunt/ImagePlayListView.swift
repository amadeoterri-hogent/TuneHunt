import SwiftUI
import Combine
import SpotifyWebAPI

struct ImagePlayListView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var createPlaylistCancellable: AnyCancellable?

    var body: some View {
        VStack {
            Button(action: createPlaylist, label: {
                Text("Create Playlist")
            })
            Spacer()
        }
    }
    
    func createPlaylist() {
        let playlistDetails = PlaylistDetails(
            name: "Test TuneHunt",
            isPublic: true,
            isCollaborative: false
        )
        
        guard let userURI = spotify.currentUser?.uri else {
            print("No current user found.")
            return
        }
        
        // Create the playlist and assign to cancellable to manage memory.
        createPlaylistCancellable = spotify.api.createPlaylist(for: userURI, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Playlist created successfully.")
                    case .failure(let error):
                        print("Failed to create playlist: \(error)")
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

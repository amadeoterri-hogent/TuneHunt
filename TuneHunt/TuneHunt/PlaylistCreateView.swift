import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistCreateView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var alertItem: AlertItem? = nil
    
    @State private var createdPlaylist: Playlist<PlaylistItems>? = nil
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Enter playlist name...",text: $namePlaylist)
                }

                Section {
                    Button {
                        // Create playlist and dismiss sheet
                        createPlaylist()
                    } label: {
                        HStack {
                            Image(systemName: "plus")
                            Text("Create playlist")
                        }
                    }
                    .foregroundStyle(Theme(colorScheme).textColor)
                    .padding()
                    .background(.green)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)

            }
            .scrollContentBackground(.hidden)
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    func createPlaylist() {
        
        if self.namePlaylist == "" {
            self.alert = AlertItem(
                title: "Couldn't create playlist",
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
        
        createPlaylistCancellable = spotify.api.createPlaylist(for: userURI, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Playlist created successfully.")
                        // Dismiss the sheet
                        dismiss()
                    case .failure(let error):
                        print("Failed to create playlist: \(error)")
                        self.alert = AlertItem(
                            title: "Failed to create playlist",
                            message: "There went something wrong while creating a playlist."
                        )
                    }
                },
                receiveValue: { playlist in
                    self.createdPlaylist = playlist
                    print("Created playlist:", playlist)
                }
            )
    }
}

#Preview{
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
        
    return PlaylistCreateView(spotify: spotify)
}

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistCreateView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var shouldRefreshPlaylists: Bool

    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var selection: Int? = nil
    @State private var selectedArtists: [Artist]
    @State private var alertItem: AlertItem? = nil
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    @State private var createdPlaylist: Playlist<PlaylistItems>? = nil
    
    init(artists: [Artist], shouldRefreshPlaylists: Binding<Bool>) {
        self._selectedArtists = State(initialValue: artists)
        self._shouldRefreshPlaylists = shouldRefreshPlaylists
    }
    
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
                    .foregroundStyle(textColor)
                    .padding()
                    .background(.green)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)

            }
            .scrollContentBackground(.hidden)
        }
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea())
        .foregroundStyle(textColor)

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
                        shouldRefreshPlaylists = true
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

struct PlaylistCreateView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
    @State static var shouldRefreshPlaylists = false
    
    static var previews: some View {
        PlaylistCreateView(artists: artists, shouldRefreshPlaylists: $shouldRefreshPlaylists)
            .environmentObject(spotify)
    }
}

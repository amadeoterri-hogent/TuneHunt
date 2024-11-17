import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistCreateView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme

    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var selection: Int? = nil
    @State private var shouldNavigate = false
    @State private var selectedArtists: [Artist]
    @State private var alertItem: AlertItem? = nil
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    @State private var createdPlaylist: Playlist<PlaylistItems>? = nil
    
    init(artists:[Artist]) {
        self.selectedArtists = artists
    }
    
    var body: some View {
        // TODO: styling
        VStack {
            TextField("Enter playlist...",text: $namePlaylist)
            Button {
                selection = 1
                createPlaylist()
            }
            label: {
                Text("Create Playlist")
            }
            .frame(maxWidth: .infinity,alignment: .leading)
            .buttonStyle(.bordered)
        }
        .navigationDestination(isPresented: $shouldNavigate) {
            destinationView()
        }
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(textColor)

    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            if let playlist = createdPlaylist {
                FinishView(playlist: playlist, artists: selectedArtists)
            } else {
                // TODO: Throw alert?
                EmptyView()
            }
        default:
            EmptyView()
        }
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
        
        createPlaylistCancellable = spotify.api.createPlaylist(for: userURI, playlistDetails)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Playlist created successfully.")
                        shouldNavigate = true
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


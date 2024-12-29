import SwiftUI
import Combine
import SpotifyWebAPI

// TODO: Edit button and layout
struct PlaylistCreateView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var alertItem: AlertItem? = nil
    @State private var createdPlaylist: Playlist<PlaylistItems>? = nil
    
    var onPlaylistCreated: ((Playlist<PlaylistItemsReference>) -> Void)?
    
    var body: some View {
        VStack {
            txtCreatePlaylist
            btnCreatePlaylist
                .padding(.vertical)
            Spacer()
        }
        .padding()
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    var txtCreatePlaylist: some View {
        TextField("Enter playlist name...", text: $namePlaylist)
            .padding(.leading, 28)
            .submitLabel(.search)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(overlayCreatePlaylist)
    }
    
    var overlayCreatePlaylist: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Spacer()
            if !namePlaylist.isEmpty {
                btnClearText
            }
        }
        .padding()
    }
    
    var btnClearText: some View {
        Button(action: {
            self.namePlaylist = ""
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        })
    }
    
    var btnCreatePlaylist: some View {
        Button {
            // Create playlist and dismiss sheet
            createPlaylist()
        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Create playlist")
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    func createPlaylist() {
        if !validate() {
            return
        }
        
        let playlistDetails = PlaylistDetails(
            name: self.namePlaylist,
            isPublic: true,
            isCollaborative: false
        )
        
        guard let userURI = spotify.currentUser?.uri else {
            self.alert = AlertItem(
                title: "User not found",
                message: "Please make sure you are logged in."
            )
            return
        }
        
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
                    // Create a new Playlist<PlaylistItemsReference>
                    let playlistReference = Playlist<PlaylistItemsReference>(
                        name: playlist.name,
                        items: PlaylistItemsReference(href: playlist.items.href, total: 0),
                        owner: playlist.owner,
                        isPublic: playlist.isPublic,
                        isCollaborative: playlist.isCollaborative,
                        description: playlist.description,
                        snapshotId: playlist.snapshotId,
                        externalURLs: playlist.externalURLs,
                        followers: playlist.followers,
                        href: playlist.href,
                        id: playlist.id,
                        uri: playlist.uri,
                        images: playlist.images
                    )
                    onPlaylistCreated?(playlistReference)
                }
            )
    }
    
    func validate() -> Bool {
        if self.namePlaylist == "" {
            self.alert = AlertItem(
                title: "Couldn't create playlist",
                message: "Playlist name is empty."
            )
            return false
        }
        
        return true
    }
}

#Preview{
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    return PlaylistCreateView()
        .environmentObject(spotify)
}

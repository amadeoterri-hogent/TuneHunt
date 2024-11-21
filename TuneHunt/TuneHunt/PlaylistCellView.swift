import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @EnvironmentObject var spotify: Spotify

    @State var playlist: Playlist<PlaylistItemsReference>
    @State private var image = Image("spotify logo green")
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    @State private var selectedPlaylist: Playlist<PlaylistItems>? = nil
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    @State var selectedArtists: [Artist]
    
    var body: some View {
        Button {
            self.playlist = playlist
            selection = 1
            loadPlaylist(playlist: playlist)
            shouldNavigate = true
        } label: {
            HStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 70, height: 70)
                    .padding(.trailing, 5)
                Text("\( playlist.name)")
            }
            .onAppear(perform: loadImage)
        }
        .navigationDestination(isPresented: $shouldNavigate) {
            destinationView()
        }
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
    
    func loadImage() {
        if self.didRequestImage { return }
        self.didRequestImage = true
        
        guard let spotifyImage = playlist.images.largest else {
            return
        }
        
        self.loadImageCancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.image = image
                }
            )
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

import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @ObservedObject var spotify: Spotify

    @State private var image = Image(.spotifyLogoGreen)
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    @State private var selectedPlaylist: Playlist<PlaylistItems>? = nil
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    @State var artists: [Artist]
    
    let playlist: Playlist<PlaylistItemsReference>
    
    init(spotify: Spotify, playlist: Playlist<PlaylistItemsReference>, artists: [Artist]) {
        self.spotify = spotify
        self.playlist = playlist
        self.artists = artists
    }
    
    var body: some View {
        Button {
            selection = 1
            loadPlaylist()
            shouldNavigate = true
        } label: {
            HStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:48,height: 48)
                    .padding(.trailing, 5)
                VStack {
                    Text("\( playlist.name)")
                }
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
                FinishView(playlist: playlist, artists: artists)
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
    
    func loadPlaylist() {
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

struct PlaylistCellView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
    static var previews: some View {
        List {
            PlaylistCellView(spotify: spotify, playlist: .thisIsMildHighClub, artists: artists)
            PlaylistCellView(spotify: spotify, playlist: .thisIsRadiohead, artists: artists)
            PlaylistCellView(spotify: spotify, playlist: .modernPsychedelia, artists: artists)
            PlaylistCellView(spotify: spotify, playlist: .rockClassics, artists: artists)
            PlaylistCellView(spotify: spotify, playlist: .menITrust, artists: artists)
        }
        .environmentObject(spotify)
    }
}

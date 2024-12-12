import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @EnvironmentObject var spotify: Spotify
    @Binding var shouldNavigate: Bool
    @Binding var selectedPlaylist: Playlist<PlaylistItems>?

    @State private var image = Image(.spotifyLogoGreen)
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var loadPlaylistCancellable: AnyCancellable? = nil
    
    var playlist: Playlist<PlaylistItemsReference>
    
    var body: some View {
        Button {
            loadPlaylist()
        } label: {
            HStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:48,height: 48)
                    .padding(.trailing, 4)
                VStack {
                    Text("\(playlist.name)")
                }
            }
            .onAppear(perform: loadImage)
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
                receiveCompletion:{ _ in
                    shouldNavigate = true
                },
                receiveValue: { playlist in
                    self.selectedPlaylist = playlist
                }
            )
    }
}

//#Preview {
//    let spotify: Spotify = {
//        let spotify = Spotify()
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    let artists: [Artist] = [
//        .pinkFloyd,.radiohead
//    ]
//    
//    return List {
//        PlaylistCellView(spotify: spotify,selectedPlaylist: nil, playlist: .thisIsMildHighClub)
//        PlaylistCellView(spotify: spotify,selectedPlaylist: nil, playlist: .thisIsRadiohead)
//        PlaylistCellView(spotify: spotify,selectedPlaylist: nil, playlist: .modernPsychedelia)
//        PlaylistCellView(spotify: spotify,selectedPlaylist: nil, playlist: .rockClassics)
//        PlaylistCellView(spotify: spotify,selectedPlaylist: nil, playlist: .menITrust)
//    }
//}

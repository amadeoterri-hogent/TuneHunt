import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @EnvironmentObject var spotify: Spotify

    @State private var image = Image(.spotifyLogoGreen)
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    
    var playlist: Playlist<PlaylistItemsReference>
    var loadPlaylist: ((Playlist<PlaylistItemsReference>) -> Void)?
    
    var body: some View {
        Button {
            loadPlaylist?(playlist)
        } label: {
            HStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .padding(.trailing, 4)
                Text("\(playlist.name)")
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
}

#Preview {
    let spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    
    PlaylistCellView(playlist: .thisIsMildHighClub)

}

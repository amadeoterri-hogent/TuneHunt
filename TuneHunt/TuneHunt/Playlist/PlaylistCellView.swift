import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @ObservedObject var playlistViewModel: PlaylistViewModel
    
    var userPlaylist: PlaylistModel.UserPlaylist
    
    var body: some View {
        Button {
            playlistViewModel.loadPlaylist(selectedPlaylist: userPlaylist.playlist)
        } label: {
            HStack {
                (userPlaylist.image ?? Image(.spotifyLogoGreen))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .padding(.trailing, 4)
                Text(userPlaylist.playlist.name)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                if userPlaylist.image == nil {
                    playlistViewModel.loadImage(for: userPlaylist)
                }
            }
        }
    }
}

#Preview {
    let playlistViewModel: PlaylistViewModel = PlaylistViewModel()
    
    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))

}

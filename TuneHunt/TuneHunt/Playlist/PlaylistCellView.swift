import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @ObservedObject var finishViewModel: FinishViewModel
    
    var userPlaylist: PlaylistModel.UserPlaylist
    
    var body: some View {
        Button {
            playlistViewModel.searchTopTracks(userPlaylist: userPlaylist, finishViewModel: finishViewModel)
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
        .disabled(playlistViewModel.isSearchingTracks)
    }
}

//#Preview {
//    let playlistViewModel: PlaylistViewModel = PlaylistViewModel()
//    
//    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
//    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
//    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
//    PlaylistCellView(playlistViewModel: playlistViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
//
//}

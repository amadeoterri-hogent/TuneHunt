import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct PlaylistCellView: View {
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @ObservedObject var finishViewModel: FinishViewModel<PlaylistItemsReference>
    
    var userPlaylist: PlaylistModel<PlaylistItemsReference>.UserPlaylist
    
    var body: some View {
        Button {
            if finishViewModel.selectedPlaylist != nil && !finishViewModel.tracks.isEmpty {
                playlistViewModel.searchTopTracks(userPlaylist: userPlaylist, finishViewModel: finishViewModel)
            } else {
                playlistViewModel.alertItem = AlertItem(
                    title: "Couldn't Resume",
                    message: "Playlist or tracks are empty"
                )
            }
        } label: {
            HStack {
                (userPlaylist.image ?? Image(systemName: "music.note.list"))
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

#Preview {
    let playlistViewModel = PlaylistViewModel()
    let finishViewModel: FinishViewModel<PlaylistItemsReference> = FinishViewModel()
    
    PlaylistCellView(playlistViewModel: playlistViewModel, finishViewModel: finishViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub))
    PlaylistCellView(playlistViewModel: playlistViewModel, finishViewModel: finishViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .lucyInTheSkyWithDiamonds))
    PlaylistCellView(playlistViewModel: playlistViewModel, finishViewModel: finishViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .menITrust))
    PlaylistCellView(playlistViewModel: playlistViewModel, finishViewModel: finishViewModel, userPlaylist: PlaylistModel.UserPlaylist(playlist: .thisIsSonicYouth))

}

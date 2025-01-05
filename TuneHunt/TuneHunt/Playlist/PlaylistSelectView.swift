import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import SpotifyExampleContent


struct PlaylistSelectView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playlistViewModel: PlaylistViewModel
    @StateObject var finishViewModel: FinishViewModel<PlaylistItemsReference> = FinishViewModel()
        
    var body: some View {
        ZStack {
            ScrollView {
                DefaultNavigationTitleView(titleText: "Select a Playlist")
                playlistView
            }
            .scrollIndicators(.hidden)
            .padding()
            .sheet(isPresented: $playlistViewModel.showCreatePlaylist) {
                PlaylistCreateView(playlistViewModel: playlistViewModel)
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .foregroundStyle(Theme(colorScheme).textColor)
            .navigationDestination(isPresented: $playlistViewModel.shouldNavigate) {
                FinishView(finishViewModel: finishViewModel)
            }
            .alert(item: $playlistViewModel.alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .onAppear(perform: playlistViewModel.retrievePlaylists)
            .toolbar {
                btnCreatePlaylist
            }

            if playlistViewModel.isLoading {
                DefaultProgressView(progressViewText: "Loading...")
            }
            
            if playlistViewModel.isSearchingTracks {
                DefaultProgressView(progressViewText: "Searching tracks...")
            }
        }
    }
    
    var playlistView: some View {
        Group {
            if playlistViewModel.hasPlaylists() {
                DefaultCaption(captionText: "Tap a playlist to proceed")
                    .padding(.top, 8)
                lstPlaylists
            }
            else {
                DefaultNoResults()
            }
        }
    }
    
    var lstPlaylists: some View {
        ForEach(playlistViewModel.userPlaylists, id: \.playlist.uri) { userPlaylist in
            PlaylistCellView(
                playlistViewModel: playlistViewModel,
                finishViewModel: finishViewModel,
                userPlaylist: userPlaylist
            )
        }
    }
    
    var btnCreatePlaylist: some View {
        Button {
            playlistViewModel.showCreatePlaylist = true
        } label: {
            Image(systemName: "plus" )
                .font(.title2)
                .frame(width:48, height: 48)
                .foregroundStyle(Theme(colorScheme).textColor)
        }
    }

}

#Preview {
    let userPlaylists: [PlaylistModel.UserPlaylist] = [
        PlaylistModel.UserPlaylist(playlist: .menITrust),
        PlaylistModel.UserPlaylist(playlist: .modernPsychedelia),
        PlaylistModel.UserPlaylist(playlist: .lucyInTheSkyWithDiamonds),
        PlaylistModel.UserPlaylist(playlist: .rockClassics),
        PlaylistModel.UserPlaylist(playlist: .thisIsMFDoom),
        PlaylistModel.UserPlaylist(playlist: .thisIsSonicYouth),
        PlaylistModel.UserPlaylist(playlist: .thisIsMildHighClub),
        PlaylistModel.UserPlaylist(playlist: .thisIsSkinshape),
    ]
    
//    let userPlaylists: [PlaylistModel.UserPlaylist] = []
    
    let playlistModel = PlaylistModel(userPlaylists: userPlaylists)
    let playlistViewModel = PlaylistViewModel(playlistModel: playlistModel)
    
    PlaylistSelectView(playlistViewModel: playlistViewModel)
}

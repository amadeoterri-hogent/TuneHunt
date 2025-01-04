import SwiftUI
import SpotifyWebAPI
import Combine
import Foundation

struct FinishView <Items: Codable & Hashable> : View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var finishViewModel : FinishViewModel<Items>
    
    var body: some View {
        ZStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Complete Playlist")
                btnAddTracksToPlaylist
                playlistView
                tracksView
                
                Spacer()
            }
            .padding()
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .alert(item: $finishViewModel.alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .navigationDestination(isPresented: $finishViewModel.shouldNavigateProgress) {
                if finishViewModel.loadedPlaylist != nil {
                    FinishProgressView(finishViewModel: finishViewModel)
                }
            }
            
        }
    }
    
    var btnAddTracksToPlaylist: some View {
        Button {
            finishViewModel.loadPlaylist()
            finishViewModel.shouldNavigateProgress = true
        } label: {
            HStack {
                Image(systemName: "rectangle.badge.plus")
                Text("Add tracks to playlist")
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var playlistView: some View {
        HStack {
            imgPlaylist
            lblPlaylist
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical,24)
    }
    
    var imgPlaylist: some View {
        Group {
            if let selectedPlaylist = finishViewModel.finishModel.selectedPlaylist {
                (selectedPlaylist.image ?? Image(systemName: "music.note.list"))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .padding(.trailing, 4)
            }
        }
    }
    
    var lblPlaylist: some View {
        VStack(alignment: .leading) {
            if let selectedPlaylist = finishViewModel.finishModel.selectedPlaylist {
                Text(selectedPlaylist.playlist.name)
                    .font(.title)
                if let owner = selectedPlaylist.playlist.owner?.displayName {
                    Text(owner)
                        .font(.subheadline)
                }
            }
        }
    }
    
    var tracksView: some View {
        VStack {
            txtTracksView
            lstTracks
        }
    }
    
    var txtTracksView: some View {
        Text("Tracks (\(finishViewModel.trackResults.count))")
            .font(.title2)
            .foregroundColor(Theme(colorScheme).textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var lstTracks: some View {
        ScrollView {
            LazyVStack {
                ForEach(finishViewModel.trackResults, id: \.track.id) { trackResult in
                    TrackCellView(finishViewModel: finishViewModel, trackResult: trackResult)
                }
            }
        }
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    let playlist: PlaylistModel.UserPlaylist = PlaylistModel.UserPlaylist(playlist: .crumb)
    let trackResults: [FinishModel<PlaylistItems>.TrackResult] = [
        FinishModel.TrackResult(track: .because),
        FinishModel.TrackResult(track: .comeTogether),
        FinishModel.TrackResult(track: .faces),
        FinishModel.TrackResult(track: .illWind),
        FinishModel.TrackResult(track: .odeToViceroy),
        FinishModel.TrackResult(track: .reckoner),
        FinishModel.TrackResult(track: .theEnd)

    ]
    let finishModel: FinishModel<PlaylistItems> = FinishModel(selectedPlaylist: playlist, trackResults: trackResults)
    let finishViewModel: FinishViewModel = FinishViewModel(finishModel: finishModel)
    
    FinishView(finishViewModel: finishViewModel)
}


import SwiftUI
import SpotifyWebAPI
import Combine
import Foundation

struct FinishView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var finishViewModel: FinishViewModel
    
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
                (selectedPlaylist.image ?? Image(.spotifyLogoGreen))
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
        Text("Tracks (\(finishViewModel.finishModel.tracks.count))")
            .font(.title2)
            .foregroundColor(Theme(colorScheme).textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var lstTracks: some View {
        ScrollView {
            LazyVStack {
                ForEach(finishViewModel.finishModel.tracks, id: \.self) { track in
                    TrackCellView(track: track)
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

//#Preview {
//    
//    let spotify = {
//        let spotify = Spotify.shared
//        //        spotify.isAuthorized = false
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    let playlist: Playlist = .crumb
//    let artists: [Artist] = [
//        .pinkFloyd,.radiohead
//    ]
//    let tracks: [Track] = [
//        .because,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,
//    ]
//    
//    FinishView(tracks: tracks, playlist: playlist , artists: artists)
//        .environmentObject(spotify)
//}


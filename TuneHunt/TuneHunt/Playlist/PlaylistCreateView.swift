import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistCreateView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playlistViewModel: PlaylistViewModel
        
    var body: some View {
        VStack {
            txtCreatePlaylist
            btnCreatePlaylist
                .padding(.vertical)
            Spacer()
        }
        .padding()
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    var txtCreatePlaylist: some View {
        TextField("Enter playlist name...", text: $playlistViewModel.newPlaylistName)
            .padding(.leading, 28)
            .submitLabel(.search)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(overlayCreatePlaylist)
    }
    
    var overlayCreatePlaylist: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Spacer()
            if !playlistViewModel.newPlaylistName.isEmpty {
                btnClearText
            }
        }
        .padding()
    }
    
    var btnClearText: some View {
        Button(action: {
            playlistViewModel.newPlaylistName = ""
        }, label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        })
    }
    
    var btnCreatePlaylist: some View {
        Button {
            playlistViewModel.createPlaylist()

        } label: {
            HStack {
                Image(systemName: "plus")
                Text("Create playlist")
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

//#Preview{
//    let spotify: Spotify = {
//        let spotify = Spotify.shared
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    return PlaylistCreateView()
//        .environmentObject(spotify)
//}

import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistSearchArtistsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var playlistSearchArtistsViewModel: PlaylistSearchArtistsViewModel
    @StateObject var artistSearchResultViewModel = ArtistSearchResultViewModel()

    var body: some View {
        ZStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Search For Playlist")
                txtSearchPlaylist
                DefaultCaption(captionText: "Tap a playlist to proceed")
                playlistSearchResults
            }
            .padding()
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .foregroundStyle(Theme(colorScheme).textColor)
            .navigationDestination(isPresented: $playlistSearchArtistsViewModel.shouldNavigate) {
                ArtistSearchResultsListView(artistSearchResultViewModel: artistSearchResultViewModel)
            }
            .alert(item: $playlistSearchArtistsViewModel.alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            
            if playlistSearchArtistsViewModel.isSearching {
                DefaultProgressView(progressViewText: "Searching...")
            }
        }
    }
    
    var txtSearchPlaylist: some View {
        TextField("Search playlist in spotify...", text: $playlistSearchArtistsViewModel.searchText, onCommit: playlistSearchArtistsViewModel.searchPlaylist)
            .padding(.leading, 36)
            .submitLabel(.search)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(overlaySearchPlaylist)
    }
    
    var overlaySearchPlaylist: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Spacer()
            if !playlistSearchArtistsViewModel.searchText.isEmpty {
                btnClearText
            }
        }
        .padding()
    }
    
    var btnClearText: some View {
        Button {
            playlistSearchArtistsViewModel.clear()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
    
    var playlistSearchResults: some View {
        Group {
            if playlistSearchArtistsViewModel.playlists.isEmpty {
                DefaultNoResults()
            }
            else {
                lstPlaylists
            }
        }
    }
    
    var lstPlaylists: some View {
        List {
            ForEach(playlistSearchArtistsViewModel.playlists, id: \.self) { playlist in
                Button {
                    playlistSearchArtistsViewModel.findArtists(playlist:playlist, artistSearchResultViewModel: artistSearchResultViewModel)
                } label: {
                    Text("\(playlist.name)")
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    let playlists: [Playlist] = [
        .modernPsychedelia,
        .rockClassics,
        .menITrust,
        .thisIsRadiohead
    ]
    
//    let playlist: [Playlist] = []
    
    let playlistSearchArtistsModel = PlaylistSearchArtistsModel(playlists: playlists)
    let playlistSearchArtistsViewModel = PlaylistSearchArtistsViewModel(playlistSearchArtistsModel: playlistSearchArtistsModel)

    PlaylistSearchArtistsView(playlistSearchArtistsViewModel: playlistSearchArtistsViewModel)
}

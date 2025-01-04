import SwiftUI
import SpotifyWebAPI
import Combine


struct ArtistSearchResultsListView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var artistSearchResultViewModel: ArtistSearchResultViewModel
    @StateObject var playlistViewModel: PlaylistViewModel = PlaylistViewModel()
    
    var body: some View {
        VStack {
            DefaultNavigationTitleView(titleText: "Select artists")
            btnSelectSpotifyPlaylist
            toggleSelectAllArtists
            lstArtists
        }
        .padding()
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .navigationDestination(isPresented: $artistSearchResultViewModel.shouldNavigate) {
            if !playlistViewModel.artists.isEmpty {
                PlaylistSelectView(playlistViewModel: playlistViewModel)
            }
        }
    }
    
    var btnSelectSpotifyPlaylist: some View {
        Button {
            playlistViewModel.playlistModel.artists = artistSearchResultViewModel.artists
            artistSearchResultViewModel.shouldNavigate = true
        } label: {
            HStack {
                Image(systemName: "music.note.list")
                Text("Select spotify playlist")
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(playlistViewModel.isSearchingTracks)
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
    }
    
    var toggleSelectAllArtists: some View {
        Group {            
            Toggle("Select All", isOn: $artistSearchResultViewModel.selectAll)
                .frame(alignment: .trailing)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
        }
    }
    
    var lstArtists: some View {
        List($artistSearchResultViewModel.artistModel.artistSearchResults, id: \.id) { $artistSearchResult in
            ArtistCellView(
                artistSearchResultViewModel: artistSearchResultViewModel,
                artistSearchResult: $artistSearchResult
            )
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

}

#Preview {
    let artistSearchResults: [ArtistModel.ArtistSearchResult] = [
        ArtistModel.ArtistSearchResult(artist: .pinkFloyd),
        ArtistModel.ArtistSearchResult(artist: .radiohead),
        ArtistModel.ArtistSearchResult(artist: .levitationRoom),
        ArtistModel.ArtistSearchResult(artist: .skinshape)
    ]
    
    let artistModel: ArtistModel = ArtistModel(artistSearchResults: artistSearchResults)
    let artistSearchResultViewModel = ArtistSearchResultViewModel(artistModel: artistModel)
    let playlistViewModel = PlaylistViewModel()
    
    ArtistSearchResultsListView(artistSearchResultViewModel: artistSearchResultViewModel, playlistViewModel: playlistViewModel)
}


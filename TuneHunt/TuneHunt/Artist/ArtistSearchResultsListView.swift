import SwiftUI
import SpotifyWebAPI
import Combine


struct ArtistSearchResultsListView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var artistSearchResultViewModel: ArtistSearchResultViewModel
    @StateObject var playlistViewModel = PlaylistViewModel()
    
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
        .alert(item: $artistSearchResultViewModel.alertItem) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .navigationDestination(isPresented: $artistSearchResultViewModel.shouldNavigate) {
            PlaylistSelectView(playlistViewModel: playlistViewModel)
        }
    }
    
    var btnSelectSpotifyPlaylist: some View {
        Button {
            if !artistSearchResultViewModel.artists.isEmpty {
                playlistViewModel.setArtists(artistSearchResultViewModel.artists)
                artistSearchResultViewModel.shouldNavigate = true
            } else {
                artistSearchResultViewModel.alertItem = AlertItem(
                    title: "Couldn't Resume",
                    message: "Please select an artist"
                )
            }
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
        List(artistSearchResultViewModel.artistSearchResults, id: \.id) { artistSearchResult in
            ArtistCellView(
                artistSearchResultViewModel: artistSearchResultViewModel,
                artistSearchResult: artistSearchResult
            )
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }

}

#Preview {
    let artistSearchResults: [ArtistSearchResult] = [
        ArtistSearchResult(artist: .pinkFloyd),
        ArtistSearchResult(artist: .radiohead),
        ArtistSearchResult(artist: .levitationRoom),
        ArtistSearchResult(artist: .skinshape)
    ]
    
    let artistModel = ArtistModel(artistSearchResults: artistSearchResults)
    let artistSearchResultViewModel = ArtistSearchResultViewModel(artistModel: artistModel)
    let playlistViewModel = PlaylistViewModel()
    
    ArtistSearchResultsListView(artistSearchResultViewModel: artistSearchResultViewModel, playlistViewModel: playlistViewModel)
}


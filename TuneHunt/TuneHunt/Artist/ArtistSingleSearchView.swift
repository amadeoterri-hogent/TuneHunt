import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistSingleSearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var spotify: Spotify
    @ObservedObject var artistSingleSearchViewModel: ArtistSingleSearchViewModel
    
    init(spotify: Spotify, artistSingleSearchViewModel: ArtistSingleSearchViewModel) {
        self.spotify = spotify
        self.artistSingleSearchViewModel = artistSingleSearchViewModel
    }
    
    var body: some View {
        ZStack {
            artistSingleSearchView
            
            if artistSingleSearchViewModel.isSearching {
                DefaultProgressView(progressViewText: "Searching...")
            }
        }
    }
    
    var artistSingleSearchView: some View {
        VStack {
            DefaultNavigationTitleView(titleText: "Search For Artist")
            searchBar
            DefaultCaption(captionText: "Tap an artist to proceed")
            artistsView
            Spacer()
        }
        .padding()
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
        .navigationDestination(isPresented: $artistSingleSearchViewModel.shouldNavigate) {
            if !artistSingleSearchViewModel.selectedArtists.isEmpty {
                PlaylistSelectView(artists: artistSingleSearchViewModel.selectedArtists)
            }
        }
        .alert(item: $artistSingleSearchViewModel.alertItem) { alert in
            Alert(title: alert.title, message: alert.message)
        }
    }
    
    var searchBar: some View {
        TextField("Search artist in spotify...", text: $artistSingleSearchViewModel.searchText, onCommit: artistSingleSearchViewModel.search)
            .padding(.leading, 36)
            .submitLabel(.search)
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(10)
            .overlay(overlaySearchBar)
    }
    
    var overlaySearchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            Spacer()
            if !artistSingleSearchViewModel.searchText.isEmpty {
                btnClearSearch
            }
        }
        .padding()
    }
    
    var btnClearSearch: some View {
        Button {
            artistSingleSearchViewModel.clear()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
    
    var artistsView: some View {
        Group {
            if artistSingleSearchViewModel.artists.isEmpty && !artistSingleSearchViewModel.isSearching {
                DefaultNoResults()
            }
            else {
                lstArtists
            }
        }
    }
    
    var lstArtists: some View {
        List {
            ForEach(artistSingleSearchViewModel.artists, id: \.self) { artist in
                Button {
                    artistSingleSearchViewModel.select(artist)
                } label: {
                    Text("\(artist.name)")
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
    }
}

#Preview{
    let spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    let artistSingleSearchViewModel = ArtistSingleSearchViewModel(spotify: spotify, isPreview: true)

    ArtistSingleSearchView(spotify: spotify, artistSingleSearchViewModel: artistSingleSearchViewModel)
}

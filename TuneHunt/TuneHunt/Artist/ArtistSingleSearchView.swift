import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistSingleSearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var searchArtistViewModel: SearchArtistViewModel
    
    var body: some View {
        ZStack {
            artistSingleSearchView
            
            if searchArtistViewModel.isSearching {
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
        .navigationDestination(isPresented: $searchArtistViewModel.shouldNavigate) {
            if !searchArtistViewModel.selectedArtists.isEmpty {
                PlaylistSelectView(artists: searchArtistViewModel.selectedArtists)
            }
        }
        .alert(item: $searchArtistViewModel.alertItem) { alert in
            Alert(title: alert.title, message: alert.message)
        }
    }
    
    var searchBar: some View {
        TextField("Search artist in spotify...", text: $searchArtistViewModel.searchText, onCommit: searchArtistViewModel.searchSingleArtist)
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
            if !searchArtistViewModel.searchText.isEmpty {
                btnClearSearch
            }
        }
        .padding()
    }
    
    var btnClearSearch: some View {
        Button {
            searchArtistViewModel.clear()
        } label: {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.secondary)
        }
    }
    
    var artistsView: some View {
        Group {
            if searchArtistViewModel.artists.isEmpty && !searchArtistViewModel.isSearching {
                DefaultNoResults()
            }
            else {
                lstArtists
            }
        }
    }
    
    var lstArtists: some View {
        List {
            ForEach(searchArtistViewModel.artists, id: \.self) { artist in
                Button {
                    searchArtistViewModel.select(artist)
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
    let searchArtistViewModel = SearchArtistViewModel()
    ArtistSingleSearchView(searchArtistViewModel: searchArtistViewModel)
}

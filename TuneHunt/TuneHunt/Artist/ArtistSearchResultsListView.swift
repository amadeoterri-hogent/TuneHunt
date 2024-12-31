import SwiftUI
import SpotifyWebAPI
import Combine


struct ArtistSearchResultsListView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate = false
    @State private var spotifyArtists: [Artist] = []
    
    @State var artistsSearchResults: [ArtistSearchResult]
    
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
        .navigationDestination(isPresented: $shouldNavigate) {
//            PlaylistSelectView(artists: $spotifyArtists)
        }
    }
    
    var btnSelectSpotifyPlaylist: some View {
        Button {
            for artistsSearchResult in artistsSearchResults {
                if artistsSearchResult.addToPlaylist {
                    spotifyArtists.append(artistsSearchResult.artist)
                }
            }
            shouldNavigate = true
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Select spotify playlist")
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
    }
    
    var toggleSelectAllArtists: some View {
        Group {
            let selectAll = Binding<Bool>(
                get: {
                    artistsSearchResults.allSatisfy { $0.addToPlaylist }
                },
                set: { newValue in
                    for index in artistsSearchResults.indices {
                        artistsSearchResults[index].addToPlaylist = newValue
                    }
                }
            )
            
            Toggle("Select All", isOn: selectAll)
                .frame(alignment: .trailing)
                .padding(.horizontal, 28)
                .padding(.vertical, 12)
        }
    }
    
    var lstArtists: some View {
        List($artistsSearchResults, id: \.id) { $artistSearchResult in
            ArtistCellView(artistSearchResult: $artistSearchResult)
                .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
    }
}

#Preview {
    
    let spotify: Spotify = {
        let spotify = Spotify.shared
        spotify.isAuthorized = true
        return spotify
    }()
    
    let artists = [
        ArtistSearchResult(artist: .pinkFloyd),
        ArtistSearchResult(artist: .radiohead)
    ]
    
    ArtistSearchResultsListView(artistsSearchResults: artists)
        .environmentObject(spotify)
}


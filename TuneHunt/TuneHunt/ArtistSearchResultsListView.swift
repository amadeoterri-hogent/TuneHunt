import SwiftUI
import SpotifyWebAPI
import Combine


struct ArtistSearchResultsListView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State var artistsSearchResults: [ArtistSearchResult]
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    @State private var spotifyArtists: [Artist] = []
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    var body: some View {
        // TODO: Select All toggle
        VStack {
            Form {
                List(artistsSearchResults, id: \.id) { artistSearchResult in
                    ArtistCellView(spotify: spotify, artistSearchResult: artistSearchResult)
                }
                .navigationTitle("Search Results")

                Section {
                    Button(action: {
                        selection = 1
                        for artistsSearchResult in artistsSearchResults {
                            if artistsSearchResult.addToPlaylist {
                                spotifyArtists.append(artistsSearchResult.artist)
                            }
                        }
                        shouldNavigate = true
                    }, label: {
                        Text("Choose playlist")
                    })
                    .foregroundStyle(textColor)
                } header: {
                    Text("Select or create a playlist")
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .ignoresSafeArea())
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            PlaylistMenuView(artists: spotifyArtists)
        default:
            EmptyView()
        }
    }

}

struct ArtistsSearchResultsView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static let artist1 = ArtistSearchResult(artist: Artist(name:"Pink Floyd"))
    static let artist2 = ArtistSearchResult(artist: Artist(name:"Radiohead"))
    
    static let artists = [artist1,artist2]
    
    static var previews: some View {
        ArtistSearchResultsListView(artistsSearchResults: artists)
            .environmentObject(spotify)
    }
}


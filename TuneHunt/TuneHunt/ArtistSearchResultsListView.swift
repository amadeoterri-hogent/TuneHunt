import SwiftUI
import SpotifyWebAPI
import Combine


struct ArtistSearchResultsListView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var artistsSearchResults: [ArtistSearchResult] = []
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    
    init(artistSearchResults: [ArtistSearchResult]) {
        self._artistsSearchResults = State(initialValue: artistSearchResults)
    }
    
    var body: some View {
        List(artistsSearchResults, id: \.id) { artistSearchResult in
            ArtistCellView(spotify: spotify, artistSearchResult: artistSearchResult)
        }
        .navigationTitle("Search Results")
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
        ArtistSearchResultsListView(artistSearchResults: artists)
            .environmentObject(spotify)
    }
}


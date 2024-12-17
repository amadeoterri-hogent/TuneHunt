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
    
    var body: some View {
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
        
        VStack {
            Form {
                Section {
                    Toggle("Select All", isOn: selectAll)
                        .frame(alignment: .trailing)
                        .padding(8)
                    
                    List($artistsSearchResults, id: \.id) { $artistSearchResult in
                        ArtistCellView(artistSearchResult: $artistSearchResult)
                    }
                    .navigationTitle("Search Results")
                } header: {
                    Text("Select artists")
                }
                
                Section {
                    Button {
                        selection = 1
                        for artistsSearchResult in artistsSearchResults {
                            if artistsSearchResult.addToPlaylist {
                                spotifyArtists.append(artistsSearchResult.artist)
                            }
                        }
                        shouldNavigate = true
                    } label: {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Choose playlist")
                        }
                        
                    }
                    .foregroundStyle(Theme(colorScheme).textColor)
                    .padding()
                    .background(.green)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .navigationDestination(isPresented: $shouldNavigate) {
            PlaylistSelectView(artists: $spotifyArtists)
        }
        
    }
}

#Preview {
    
    let spotify: Spotify = {
        let spotify = Spotify()
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


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
                        ArtistCellView(spotify: spotify, artistSearchResult: $artistSearchResult)
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
                    .foregroundStyle(textColor)
                    .padding()
                    .background(.green)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .listRowBackground(Color.clear)
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
    
    @State static var artists = [
        ArtistSearchResult(artist: Artist(name: "Pink Floyd")),
        ArtistSearchResult(artist: Artist(name: "Radiohead"))
    ]
    
    static var previews: some View {
        ArtistSearchResultsListView(artistsSearchResults: artists)
            .environmentObject(spotify)
    }
}


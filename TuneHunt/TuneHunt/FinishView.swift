import SwiftUI
import SpotifyWebAPI
import Combine

struct FinishView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme

    @State var tracks: [Track] = []
    @State private var searchCancellables: Set<AnyCancellable> = []
    @State private var isSearching = false
    @State private var alert: AlertItem? = nil

    var textColor: Color { colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    var playlist: Playlist<PlaylistItems>
    var artists: [Artist]
    
    var body: some View {
        VStack {
            Text("Playlist: \(playlist.name)")
            Text("Number of artists: \(artists.count) ")
            
            if isSearching {
                ProgressView("Searching top tracks...")
            } else {
                List(tracks, id: \.id) { track in
                    Text(track.name)
                }
            }
            
            Button {
                finish()
            } label: {
                Text("Finish")
            }
        }
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea())
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .onAppear {
            search()
        } 
    }
    
    func search() {
        self.tracks = []
        self.isSearching = true
        var remainingRequests = artists.count

        for artist in artists {
            if let uri = artist.uri {
                spotify.api.artistTopTracks(uri, country: "BE")
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                self.alert = AlertItem(
                                    title: "Couldn't Perform Search",
                                    message: error.localizedDescription
                                )
                            }
                            
                            remainingRequests -= 1
                            if remainingRequests == 0 {
                                self.isSearching = false
                            }
                        },
                        receiveValue: { searchResults in
                            self.tracks.append(contentsOf: searchResults)
                            print("received \(self.tracks.count) tracks")
                        }
                    )
                    .store(in: &searchCancellables)
            } else {
                // Handle artists without a URI (optional improvement)
                remainingRequests -= 1
                if remainingRequests == 0 {
                    self.isSearching = false
                }
            }
        }
    }
    
    func finish() {
        let playlistURI = playlist.uri
        let trackURIs = tracks.compactMap { $0.uri }

        guard !trackURIs.isEmpty else {
            self.alert = AlertItem(
                title: "Error",
                message: "No tracks to add to the playlist."
            )
            return
        }

        let chunks = trackURIs.chunked(into: 100) // Split track URIs into batches of 100
        var remainingChunks = chunks.count

        for chunk in chunks {
            spotify.api.addToPlaylist(playlistURI, uris: chunk)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            self.alert = AlertItem(
                                title: "Couldn't Add Tracks",
                                message: error.localizedDescription
                            )
                            remainingChunks = 0 // Stop processing if there's an error
                        } else {
                            remainingChunks -= 1
                            if remainingChunks == 0 {
                                self.alert = AlertItem(
                                    title: "Success",
                                    message: "All tracks added to the playlist successfully."
                                )
                            }
                        }
                    },
                    receiveValue: { _ in
                        print("A batch of tracks added to playlist \(playlist.name)")
                    }
                )
                .store(in: &spotify.cancellables)
        }
    }

}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// TODO: Fix preview
//struct FinishView_Previews: PreviewProvider {
//    
//    static let spotify: Spotify = {
//        let spotify = Spotify()
//        //        spotify.isAuthorized = false
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    static var previews: some View {
//        FinishView()
//            .environmentObject(spotify)
//    }
//}

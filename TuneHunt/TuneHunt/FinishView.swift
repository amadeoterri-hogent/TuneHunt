import SwiftUI
import SpotifyWebAPI
import Combine
import Foundation

// TODO: Add back to home button
// TODO: Skip track on error and print after which ones didn't succeed
// TODO: Because now you get an error message with a lot of tracks but the tracks were added to the playlist
// TODO: lazy load list
// TODO: card view playlist and playlist name
// TODO: play playlist?
struct FinishView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State var tracks: [Track] = []
    @State private var searchCancellables: Set<AnyCancellable> = []
    @State private var isSearching = false
    @State private var alert: AlertItem? = nil
    
    var playlist: Playlist<PlaylistItems>
    var artists: [Artist]
    var isPreview = false
    
    var body: some View {
        VStack {
            Text("Complete Playlist")
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text("Playlist: \(playlist.name)")
            Text("Number of artists: \(artists.count) ")
            
            Button {
                finish()
            } label: {
                Text("Add tracks to playlist")
            }
            .foregroundStyle(Theme(colorScheme).textColor)
            .padding()
            .background(.green)
            .clipShape(Capsule())
            .frame(maxWidth: .infinity, alignment: .center)
            
            
            if isSearching {
                ProgressView("Searching top tracks...")
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                List {
                    ForEach(tracks, id: \.self) { track in
                        if let artist = track.artists?[0] {
                            Text("\(artist.name) - \(track.name)")
                                .listRowBackground(Color.clear)
                        }
                    }
                    .onDelete(perform: removeTrack)
                }
                .listStyle(.plain)
            }
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .onAppear {
            search()
        }
    }
    
    private func removeTrack(at offsets: IndexSet) {
        withAnimation {
            tracks.remove(atOffsets: offsets)
        }
    }
    
    func search() {
        if isPreview {
            return
        }
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
                            for track in searchResults {
                                if !self.tracks.contains(where: { $0.id == track.id }) {
                                    self.tracks.append(track)
                                }
                            }
                        }
                    )
                    .store(in: &searchCancellables)
            } else {
                // Handle artists without a URI (optional improvement)
                remainingRequests -= 1
                if remainingRequests == 0 {
                    self.tracks = self.tracks.removingDuplicates()
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
        
        // Split track URIs into batches of 100
        let chunks = trackURIs.chunked(into: 100)
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

#Preview {
    
    let spotify: Spotify = {
        let spotify = Spotify()
        //        spotify.isAuthorized = false
        spotify.isAuthorized = true
        return spotify
    }()
    
    let playlist: Playlist = .crumb
    let artists: [Artist] = [
        .pinkFloyd,.radiohead
    ]
    let tracks: [Track] = [
        .because,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,.comeTogether,.faces,.illWind,.odeToViceroy,.reckoner,.theEnd,
    ]
    
    FinishView(tracks: tracks, playlist: playlist , artists: artists, isPreview: true)
        .environmentObject(spotify)
    
    
}


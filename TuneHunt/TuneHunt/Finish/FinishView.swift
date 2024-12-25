import SwiftUI
import SpotifyWebAPI
import Combine
import Foundation

// TODO: Skip track on error and print after which ones didn't succeed
// TODO: Because now you get an error message with a lot of tracks but the tracks were added to the playlist
// TODO: Lawy Scrollview for tracks
struct FinishView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var image = Image(.spotifyLogoGreen)
    @State private var alert: AlertItem? = nil
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate: Bool = false
    
    var tracks: [Track]
    var playlist: Playlist<PlaylistItems>
    var artists: [Artist]
    
    var body: some View {
        ZStack {
            VStack {
                Text("Complete Playlist")
                    .font(.largeTitle)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button {
                    shouldNavigate = true
                } label: {
                    Text("Add tracks to playlist")
                        .frame(maxWidth: .infinity)
                }
                .foregroundStyle(Theme(colorScheme).textColor)
                .padding()
                .background(.blue)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity, alignment: .center)
                
                HStack {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 64, height: 64)
                        .padding(.trailing, 4)
                    
                    VStack(alignment: .leading) {
                        Text(playlist.name)
                            .font(.title)
                        
                        if let owner = playlist.owner?.displayName {
                            Text(owner)
                                .font(.subheadline)
                        }
                        
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical,24)
                
                Text("Tracks (\(tracks.count))")
                    .font(.title2)
                    .foregroundColor(Theme(colorScheme).textColor)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView {
                    LazyVStack {
                        ForEach(tracks, id: \.self) { track in
                            TrackCellView(track: track)
                        }
                    }
                }
                
                Spacer()
                
            }
            .onAppear(perform: loadImage)
            .padding()
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .alert(item: $alert) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                FinishProgressView(tracks: tracks, playlist: playlist, artists: artists)
            }
            
        }
    }
    
    func loadImage() {
        guard let spotifyImage = playlist.images.largest else {
            return
        }
        
        self.loadImageCancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.image = image
                }
            )
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
    
    FinishView(tracks: tracks, playlist: playlist , artists: artists)
        .environmentObject(spotify)
}


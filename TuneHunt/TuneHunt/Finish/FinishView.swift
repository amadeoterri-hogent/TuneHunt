import SwiftUI
import SpotifyWebAPI
import Combine
import Foundation

struct FinishView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var image = Image(.spotifyLogoGreen)
    @State private var alert: AlertItem? = nil
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate = false
    
    var tracks: [Track]
    var playlist: Playlist<PlaylistItems>
    var artists: [Artist]
    
    var body: some View {
        ZStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Complete Playlist")
                btnAddTracksToPlaylist
                playlistView
                tracksView
                
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
    
    var btnAddTracksToPlaylist: some View {
        Button {
            validateAndNavigate()
        } label: {
            HStack {
                Image(systemName: "rectangle.badge.plus")
                Text("Add tracks to playlist")
            }
            .frame(maxWidth: .infinity)
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var playlistView: some View {
        HStack {
            imgPlaylist
            lblPlaylist
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical,24)
    }
    
    var imgPlaylist: some View {
        image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 64, height: 64)
            .padding(.trailing, 4)
    }
    
    var lblPlaylist: some View {
        VStack(alignment: .leading) {
            Text(playlist.name)
                .font(.title)
            
            if let owner = playlist.owner?.displayName {
                Text(owner)
                    .font(.subheadline)
            }
        }
    }
    
    var tracksView: some View {
        VStack {
            txtTracksView
            lstTracks
        }
    }
    
    var txtTracksView: some View {
        Text("Tracks (\(tracks.count))")
            .font(.title2)
            .foregroundColor(Theme(colorScheme).textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var lstTracks: some View {
        ScrollView {
            LazyVStack {
                ForEach(tracks, id: \.self) { track in
                    TrackCellView(track: track)
                }
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
    
    func validateAndNavigate() {
        guard !tracks.isEmpty else {
            self.alert = AlertItem(
                title: "Error",
                message: "No tracks to add to the playlist."
            )
            return
        }
        
        shouldNavigate = true
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
    
    let spotify = {
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


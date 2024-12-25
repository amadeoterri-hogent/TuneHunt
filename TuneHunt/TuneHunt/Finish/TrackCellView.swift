
import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

// TODO: save image like in artistsearchresults so it doesn"t get loaded every time
struct TrackCellView: View {
    @EnvironmentObject var spotify: Spotify

    @State private var image = Image(systemName: "music.note.tv")
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    
    var track: Track
    
    var body: some View {
        HStack {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .padding(.trailing, 4)
            
            VStack {
                Text(track.name)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let artist = track.artists?.first {
                    Text(artist.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
            }
        }
        .padding(.vertical, 5)
        .background(Color.clear)
        .onAppear(perform: loadImage)
    }
    
    func loadImage() {
        if self.didRequestImage { return }
        self.didRequestImage = true
        
        guard let spotifyImage = track.album?.images?.largest else {
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

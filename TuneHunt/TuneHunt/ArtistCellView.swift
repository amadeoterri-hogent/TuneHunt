import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistCellView: View {
    @ObservedObject var spotify: Spotify
    @State private var image = Image("spotify logo green")
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var artistSearchResult: ArtistSearchResult
    
    init(spotify: Spotify, artistSearchResult: ArtistSearchResult) {
        self.spotify = spotify
        self.artistSearchResult = artistSearchResult
    }

    var body: some View {
        HStack() {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .cornerRadius(5)
                .padding(.trailing, 5)

            
            Text(artistSearchResult.artist.name)
                .font(.headline)
            
            Toggle("",isOn: $artistSearchResult.addToPlaylist)
            Spacer()
        }
        .padding(.vertical, 5)
        .onAppear(perform: loadImage)
    }
    
    
    func loadImage() {
        if self.didRequestImage { return }
        self.didRequestImage = true
        
        guard let spotifyImage = artistSearchResult.artist.images?.largest else {
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

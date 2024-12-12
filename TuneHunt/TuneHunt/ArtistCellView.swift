import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistCellView: View {
    @ObservedObject var spotify: Spotify
    @Binding var artistSearchResult: ArtistSearchResult

    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    
    let placeholderImage = Image(.spotifyLogoGreen)

    var body: some View {
        HStack() {
            (artistSearchResult.image ?? placeholderImage)
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
        .onAppear {
            if artistSearchResult.image == nil {
                loadImage()
            }
        }
    }
    
    
    func loadImage() {
        print("Searching image \(artistSearchResult.artist.name)")
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
                    artistSearchResult.image = image
                }
            )
    }
    
}

#Preview {
    var artistSearchResult = ArtistSearchResult(artist: .pinkFloyd)
    
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    return List {
        ArtistCellView(spotify: spotify, artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(spotify: spotify, artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(spotify: spotify, artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(spotify: spotify, artistSearchResult: .constant(artistSearchResult))
    }
}


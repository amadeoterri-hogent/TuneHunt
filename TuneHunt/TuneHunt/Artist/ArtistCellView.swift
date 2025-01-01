import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistCellView: View {
    @EnvironmentObject var spotify: Spotify
    @Binding var artistSearchResult: SearchArtistModel.ArtistSearchResult

    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    
    let placeholderImage = Image(.spotifyLogoGreen)

    var body: some View {
        HStack() {
            imgArtist
            lblArtist
            Spacer()
        }
        .padding(.vertical, 5)
        .onAppear {
            if artistSearchResult.image == nil {
                loadImage()
            }
        }
    }
    
    var imgArtist: some View {
        (artistSearchResult.image ?? placeholderImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 60)
            .cornerRadius(5)
            .padding(.trailing, 5)
    }
    
    var lblArtist: some View {
        HStack {
            Text(artistSearchResult.artist.name)
                .font(.headline)
            
            Toggle("",isOn: $artistSearchResult.addToPlaylist)
        }
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
                    artistSearchResult.image = image
                }
            )
    }
}

#Preview {
    let artistSearchResult = SearchArtistModel.ArtistSearchResult(artist: .pinkFloyd)
    
    let spotify = {
        let spotify = Spotify.shared
        spotify.isAuthorized = true
        return spotify
    }()
    
    List {
        ArtistCellView(artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(artistSearchResult: .constant(artistSearchResult))
    }
    .environmentObject(spotify)

}


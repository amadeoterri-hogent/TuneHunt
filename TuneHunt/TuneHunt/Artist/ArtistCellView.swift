import SwiftUI
import Combine
import SpotifyWebAPI

struct ArtistCellView: View {
    @ObservedObject var artistSearchResultViewModel: ArtistSearchResultViewModel
    @Binding var artistSearchResult: ArtistModel.ArtistSearchResult

    var body: some View {
        HStack() {
            imgArtist
            lblArtist
            Spacer()
        }
        .padding(.vertical, 5)
        .onAppear {
            artistSearchResultViewModel.loadImage(for: artistSearchResult)
        }
    }
    
    var imgArtist: some View {
        (artistSearchResult.image ?? Image(.spotifyLogoGreen))
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
            
            Toggle("", isOn: $artistSearchResult.addToPlaylist)
        }
    }
}

#Preview {
    let artistSearchResult = ArtistModel.ArtistSearchResult(artist: .pinkFloyd)
    let artistSearchResultViewModel = ArtistSearchResultViewModel()

    List {
        ArtistCellView(artistSearchResultViewModel: artistSearchResultViewModel, artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(artistSearchResultViewModel: artistSearchResultViewModel, artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(artistSearchResultViewModel: artistSearchResultViewModel, artistSearchResult: .constant(artistSearchResult))
        ArtistCellView(artistSearchResultViewModel: artistSearchResultViewModel, artistSearchResult: .constant(artistSearchResult))
    }
}


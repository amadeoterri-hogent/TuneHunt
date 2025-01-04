
import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct TrackCellView <Items: Codable & Hashable>: View {
    @ObservedObject var finishViewModel: FinishViewModel<Items>
    var trackResult: FinishModel<Items>.TrackResult

    var body: some View {
        HStack {
            (trackResult.image ?? Image(systemName: "music.note.tv"))

                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 36, height: 36)
                .padding(.trailing, 4)
            
            VStack {
                Text(trackResult.track.name)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let artist = trackResult.track.artists?.first {
                    Text(artist.name)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.vertical, 5)
        .background(Color.clear)
        .onAppear {
            finishViewModel.loadImage(for: trackResult)
        }
    }

}

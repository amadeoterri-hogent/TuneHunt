import SpotifyWebAPI
import SwiftUI

struct ArtistPreviewView : View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var artists: [String]
    
    var body: some View {
        VStack {
            if artists.isEmpty {
                DefaultNoResults()
            } else {
                lstPreviewArtists
            }
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    var lstPreviewArtists: some View {
        List {
            ForEach(artists, id: \.self) {
                Text("\($0)")
                    .listRowBackground(Color.clear)
                    .foregroundStyle(Theme(colorScheme).textColor)
                
            }
            .onDelete(perform: removeArtist)
        }
        .listStyle(.plain)
        .padding(24)
    }
    
    private func removeArtist(at offsets: IndexSet) {
        withAnimation {
            // FIXME: use remove from viewmodel
            artists.remove(atOffsets: offsets)
        }
    }
}

#Preview {
    let artists = ["Pink Floyd","Radiohead","Ice Cube"]
//    let artists: [String] = []
    
    ArtistPreviewView(artists: .constant(artists))
}

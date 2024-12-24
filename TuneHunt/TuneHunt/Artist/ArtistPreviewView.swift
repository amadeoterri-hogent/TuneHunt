import SpotifyWebAPI
import SwiftUI

struct ArtistPreviewView : View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var artists: [String]
    
    var body: some View {
        VStack {
            if artists.isEmpty {
                Text("No results")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Theme(colorScheme).textColor)
                    .font(.title)
                    .opacity(0.6)
                    .foregroundColor(.secondary)
            } else {
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
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    private func removeArtist(at offsets: IndexSet) {
        withAnimation {
            artists.remove(atOffsets: offsets)
        }
    }
}

#Preview {
//    let artists: [String] = ["Pink Floyd","Radiohead","Ice Cube"]
    let artists: [String] = []
    
    ArtistPreviewView(artists: .constant(artists))
}

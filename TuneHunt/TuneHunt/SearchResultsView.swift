import SwiftUI
import SpotifyWebAPI
import Combine


struct SearchResultsView: View {
    let artists: [Artist]
    @State private var didRequestImage = false
    @State private var image = Image("spotify logo green")
    @State private var loadImageCancellable: AnyCancellable? = nil
    
    
    var body: some View {
        List(artists, id: \.id) { artist in
            VStack(alignment: .leading) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                
                Text(artist.name)
                    .font(.headline)
            }
            .padding(.vertical, 5)
            .onAppear(perform: loadImage)
        }
        .navigationTitle("Search Results")
    }
    
    func loadImage() {
        if self.didRequestImage { return }
        self.didRequestImage = true
        
        guard let spotifyImage = artists[0].images?.largest else {
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


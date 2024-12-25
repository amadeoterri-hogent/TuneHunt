import SwiftUI
import SpotifyWebAPI

// TODO: play playlist?
// TODO: new Navigationstack??

struct FinishProgressView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var progress: Double = 0.0
    @State private var animationAmount: Double = 1.0
    @State private var shouldNavigate: Bool = false
    
    var tracks: [Track]
    var playlist: Playlist<PlaylistItems>
    var artists: [Artist]
    
    var body: some View {
        VStack {
            if progress == 1.0 {
                Text("Completed")
                    .font(.title)
                    .padding(.bottom, 36)
                    .scaleEffect(animationAmount)
                    .animation(
                        .easeInOut(duration: 1).repeatCount(10, autoreverses: true),
                        value: animationAmount
                    )
                    .onAppear {
                        animationAmount = 1.2
                    }
            }
            else {
                Text("Adding tracks to playlist")
                    .font(.title)
                    .padding(.vertical, 36)
                    .scaleEffect(animationAmount)
                    .animation(
                        .easeInOut(duration: 1).repeatForever(autoreverses: true),
                        value: animationAmount
                    )
            }

            
            ProgressView(value: progress)
                .progressViewStyle(CustomCircularProgressViewStyle())
                .padding()
                    
        }
        .toolbar() {
            Button {
                shouldNavigate = true
            } label: {
                HStack {
                    Image(systemName: "house")
                    Text("Home")
                }
            }
        }
        .navigationDestination(isPresented: $shouldNavigate) {
            MenuView()
        }
        .frame(maxHeight: .infinity, alignment: .center)
        .background(
            LinearGradient(
                colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear() {
            Task {
//                await startAsyncTask()
                await finish()
            }
        }
    }
    
    func finish() async {
        let playlistURI = playlist.uri
        let trackURIs = tracks.compactMap { $0.uri }
        
//        guard !trackURIs.isEmpty else {
//            self.alert = AlertItem(
//                title: "Error",
//                message: "No tracks to add to the playlist."
//            )
//            return
//        }
                
        // Split track URIs into batches of 100
        let chunks = trackURIs.chunked(into: 100)
        var remainingChunks = chunks.count
        
        await startAsyncTask(totalChunks: Double(chunks.count))
        
        for chunk in chunks {
            spotify.api.addToPlaylist(playlistURI, uris: chunk)
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
//                        if case .failure(let error) = completion {
//                            self.alert = AlertItem(
//                                title: "Couldn't Add Tracks",
//                                message: error.localizedDescription
//                            )
//                            remainingChunks = 0 // Stop processing if there's an error
//                        } else {
                            remainingChunks -= 1
//                            if remainingChunks == 0 {
//                                self.alert = AlertItem(
//                                    title: "Success",
//                                    message: "All tracks added to the playlist successfully."
//                                )
//                            }
//                        }
                    },
                    receiveValue: { _ in
                        print("A batch of tracks added to playlist \(playlist.name)")
                    }
                )
                .store(in: &spotify.cancellables)
        }
    }
    
    
    func startAsyncTask(totalChunks: Double) async {
        animationAmount = 1.2
        for i in 0...Int(totalChunks) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            progress = Double(i) / totalChunks
        }
        // reset value
        animationAmount = 1.0

    }
}

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(Color.blue, lineWidth: 10)
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: configuration.fractionCompleted)
            Text(String(format: "%.0f%%", (configuration.fractionCompleted ?? 0) * 100))
                .font(.largeTitle)
                .bold()
        }
    }
}

//#Preview {
//    FinishProgressView()
//}

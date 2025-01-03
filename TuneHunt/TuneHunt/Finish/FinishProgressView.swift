import SwiftUI
import SpotifyWebAPI

// TODO: Skip track on error and print after which ones didn't succeed
// TODO: play playlist?

struct FinishProgressView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var finishViewModel: FinishViewModel

    @State private var progress: Double = 0.0
    @State private var animationAmount: Double = 1.0
    
    var body: some View {
        VStack {
            txtProgressStatus
            pvProgress
        }
        .padding()
        .toolbar() {btnHome}
        .navigationDestination(isPresented: $finishViewModel.shouldNavigateHome) {MenuView()}
        .frame(maxHeight: .infinity, alignment: .center)
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .onAppear() {
            Task {
                await finish()
            }
        }
    }
    
    var txtProgressStatus: some View {
        Group {
            if progress == 1.0 {
                txtCompleted
            }
            else {
                txtInProgress
            }
        }
    }
    
    var txtCompleted: some View {
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
    
    var txtInProgress: some View {
        Text("Adding tracks to playlist")
            .font(.title)
            .padding(.vertical, 36)
            .scaleEffect(animationAmount)
            .animation(
                .easeInOut(duration: 1).repeatForever(autoreverses: true),
                value: animationAmount
            )
    }
    
    var pvProgress: some View {
        ProgressView(value: progress)
            .progressViewStyle(CustomCircularProgressViewStyle())
    }
    
    var btnHome: some View {
        Button {
            finishViewModel.shouldNavigateHome = true
        } label: {
            HStack {
                Image(systemName: "house")
                Text("Home")
            }
        }
    }
    
    func finish() async {
        if let playlist = finishViewModel.loadedPlaylist {
            let trackURIs = finishViewModel.finishModel.tracks.compactMap { $0.uri }
            
            // Split track URIs into batches of 100
            let chunks = trackURIs.chunked(into: 100)
            var remainingChunks = chunks.count
            
            await startAsyncTask(totalChunks: Double(chunks.count))
            
            for chunk in chunks {
                spotify.api.addToPlaylist(playlist.uri, uris: chunk)
                    .receive(on: RunLoop.main)
                    .sink(
                        receiveCompletion: { completion in
                            remainingChunks -= 1
                        },
                        receiveValue: { _ in }
                    )
                    .store(in: &spotify.cancellables)
            }
        }
    }
    
    func startAsyncTask(totalChunks: Double) async {
        animationAmount = 1.2
        for i in 0...Int(totalChunks) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            progress = Double(i) / totalChunks
        }
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

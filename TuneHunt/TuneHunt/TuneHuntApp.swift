import SwiftUI
import SwiftData

@main
struct TuneHuntApp: App {
    
    @StateObject var spotify = Spotify()
    
    init() {
//        SpotifyAPILogHandler.bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotify)
        }
    }
}

import SwiftUI
import SwiftData

@main
struct TuneHuntApp: App {
    @StateObject var spotify = Spotify.shared
    @AppStorage("topTracks") private var topTracks = 10
    @AppStorage("country") private var country = "BE"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotify)
        }
    }
}

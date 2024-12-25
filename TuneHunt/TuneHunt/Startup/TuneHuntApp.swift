import SwiftUI
import SwiftData

@main
struct TuneHuntApp: App {
    @StateObject var spotify = Spotify()
    @AppStorage("topTracks") private var topTracks: Int = 10
    @AppStorage("country") private var country: String = "BE"

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotify)
        }
    }
}

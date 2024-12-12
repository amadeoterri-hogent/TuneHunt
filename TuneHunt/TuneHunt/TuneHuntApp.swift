import SwiftUI
import SwiftData

@main
struct TuneHuntApp: App {
    @StateObject var spotify = Spotify()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(spotify)
        }
    }
}

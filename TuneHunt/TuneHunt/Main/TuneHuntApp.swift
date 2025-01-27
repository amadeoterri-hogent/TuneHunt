import SwiftUI

typealias ArtistSearchResult = ArtistModel.ArtistSearchResult

@main
struct TuneHuntApp: App {
    @StateObject var spotify = Spotify.shared
    @StateObject var mainViewModel = MainViewModel()
    @AppStorage("topTracks") private var topTracks = 10
    @AppStorage("country") private var country = "BE"

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(spotify)
                .environmentObject(mainViewModel)
        }
    }
}

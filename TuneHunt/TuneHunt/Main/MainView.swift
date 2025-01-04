import SwiftUI
import Combine
import SpotifyWebAPI

struct MainView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var spotify: Spotify
    
    var body: some View {
        VStack() {
            if (!spotify.isAuthorized) {
                LoginView()
                    .onOpenURL(perform: mainViewModel.handleURL(_:))
            } else {
                MenuView()
            }
        }
        .accentColor(Theme(colorScheme).textColor)
    }
}

#Preview {
    let mainViewModel: MainViewModel = MainViewModel()
    MainView()
        .environmentObject(mainViewModel)
}

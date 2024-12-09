import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showGrid = false
    
    var body: some View {
        VStack {
            ProfileBarView(spotify:spotify)
            
            HStack {
                Image(systemName:"text.justify")
                Toggle("", isOn: $showGrid)
                    .labelsHidden()
                Image(systemName:"square.grid.3x3")
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !showGrid {
                MenuListView(spotify: spotify)
            } else {
                MenuGridView(spotify: spotify)

            }
        }
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
    }
}

#Preview {
    let demoUser = SpotifyUser(
        displayName: "Amadeo",
        uri: "www.google.com",
        id: "1",
        href: URL(string: "www.google.com")!
    )
    
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    
    return MenuView(spotify: spotify)
}


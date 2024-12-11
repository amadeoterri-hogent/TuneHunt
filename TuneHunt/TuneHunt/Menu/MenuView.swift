import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showGrid = false
    
    var menuItems: [MenuItem] = [
        MenuItem(selection: 1,
                 imageSystemName: "person",
                 listItemTitle: "Top tracks from single artist"),
        MenuItem(selection: 2,
                 imageSystemName: "person.3",
                 listItemTitle: "Top tracks from multiple artists"),
        MenuItem(selection: 3,
                 imageSystemName: "photo",
                 listItemTitle: "Find artists from image"),
        MenuItem(selection: 4,
                 imageSystemName: "music.note.list",
                 listItemTitle: "Find artists from other playlist")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ProfileBarView(spotify:spotify)
                
                Text("Build playlists")
                    .font(.largeTitle)
                    .bold()
                    .padding(.horizontal)
                    .padding(.top)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Image(systemName:"text.justify")
                    Toggle("", isOn: $showGrid)
                        .labelsHidden()
                    Image(systemName:"square.grid.3x3")
                }
                .padding(.horizontal)
                .padding(.top)
                .font(.subheadline)
                .opacity(0.7)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if !showGrid {
                    MenuListView(spotify: spotify, menuItems: menuItems)
                } else {
                    MenuGridView(spotify: spotify, menuItems: menuItems)
                }
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
        }
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


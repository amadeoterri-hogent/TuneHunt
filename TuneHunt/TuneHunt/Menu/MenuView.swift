import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var menuStyle: MenuStyle = .list
    
    var menuItems: [MenuItem] = [
        MenuItem(selection: 1,
                 imageSystemName: "person",
                 listItemTitle: "From top tracks by one artist"),
        MenuItem(selection: 2,
                 imageSystemName: "person.3",
                 listItemTitle: "From top tracks by multiple artists"),
        MenuItem(selection: 3,
                 imageSystemName: "photo",
                 listItemTitle: "By finding artists from image"),
        MenuItem(selection: 4,
                 imageSystemName: "music.note.list",
                 listItemTitle: "By finding artists from another playlist")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                switch menuStyle {
                    case .list:
                        MenuListView(menuItems: menuItems)
                    case .grid:
                        MenuGridView(menuItems: menuItems)
                }
            }
            .navigationBarBackButtonHidden()
            .navigationTitle("Build playlist")
            .toolbar {
                MenuProfileBarView(menuStyle: $menuStyle)
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
    
    let spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    
    return MenuView()
        .environmentObject(spotify)
}


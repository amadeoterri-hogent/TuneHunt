import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showGrid = false
    
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
                ProfileBarView()
                
                HStack {
                    Text("Build playlist")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        Image(systemName:"text.justify")
                        Toggle("", isOn: $showGrid)
                            .labelsHidden()
                            .tint(.clear)
                        Image(systemName:"square.grid.3x3")
                    }
                    .frame(alignment: .trailing)
                    .padding(.top, 4)
                    .font(.caption2)
                    .opacity(0.7)
                }
                .frame(height:48)
                .lineLimit(1)
                .padding(.horizontal)
                .padding(.top)

                if !showGrid {
                    MenuListView(menuItems: menuItems)
                } else {
                    MenuGridView(menuItems: menuItems)
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
    
    return MenuView()
        .environmentObject(spotify)
}


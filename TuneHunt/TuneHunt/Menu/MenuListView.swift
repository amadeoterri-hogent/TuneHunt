import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuListView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var menuImage = Image(.recordPlayer)
    @State private var didRequestImage = false
    @State private var showInfoText = false
    @State private var showInfoImage = false
    @State private var selection: Int = 0
    @State private var shouldNavigate = false
    
    var menuItems: [MenuItem]
    
    var body: some View {
        VStack {
            ForEach(menuItems, id: \.self) { menuItem in
                MenuListItemCell(shouldNavigate: $shouldNavigate, selection: $selection, menuItem: menuItem)
            }
            Spacer()
        }
        .padding(.top)
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .foregroundStyle(Theme(colorScheme).textColor)
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            // TODO: build from single artist
            EmptyView()
        case 2:
            ArtistTextSearchView(spotify:spotify)
        case 3:
            ArtistImageSearchView(spotify:spotify, artistSearchResults: [])
        case 4:
            // TODO: build from other playlist
            EmptyView()
        default:
            EmptyView()
        }
    }
}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
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
    
    MenuListView(spotify: spotify, menuItems: menuItems)
}
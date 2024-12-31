import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @EnvironmentObject var spotify: Spotify
    @StateObject var artistSingleSearchViewModel: ArtistSingleSearchViewModel = ArtistSingleSearchViewModel(isPreview: false)
    @Environment(\.colorScheme) var colorScheme
    
    @State private var shouldNavigate = false
    @State private var selection: Int = 0
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
                DefaultNavigationTitleView(titleText: "Build playlist")
                
                Group {
                    switch menuStyle {
                    case .list:
                        menuListView
                    case .grid:
                        menuGridView
                    }
                    Spacer()
                }
                .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
                .foregroundStyle(Theme(colorScheme).textColor)
            }
            .padding()
            .navigationBarBackButtonHidden()
            .toolbar {
                MenuProfileBarView(menuStyle: $menuStyle)
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
        }
    }
    
    var menuListView: some View {
        VStack {
            ForEach(menuItems, id: \.self) { menuItem in
                MenuListItemCell(shouldNavigate: $shouldNavigate, selection: $selection, menuItem: menuItem)
            }
        }
    }
    
    var menuGridView: some View {
        VStack {
            let columns = [GridItem(.adaptive(minimum: 144))]
            
            LazyVGrid (columns: columns) {
                ForEach(menuItems, id: \.self) { menuItem in
                    MenuGridItemCell(shouldNavigate: $shouldNavigate, selection: $selection, menuItem: menuItem)
                        .padding(12)
                }
            }
        }
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistSingleSearchView(artistSingleSearchViewModel: artistSingleSearchViewModel)
        case 2:
            ArtistMultipleSearchView()
        case 3:
            ArtistImageSearchView()
        case 4:
            PlaylistSearchArtistsView()
        default:
            EmptyView()
        }
    }
}

//#Preview {
//    let demoUser = SpotifyUser(
//        displayName: "Amadeo",
//        uri: "www.google.com",
//        id: "1",
//        href: URL(string: "www.google.com")!
//    )
//
//    let spotify = {
//        let spotify = Spotify.shared
//        spotify.isAuthorized = true
//        spotify.currentUser = demoUser
//        return spotify
//    }()
//
//    return MenuView()
//        .environmentObject(spotify)
//}


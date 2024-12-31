import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @StateObject var artistSingleSearchViewModel: ArtistSingleSearchViewModel = ArtistSingleSearchViewModel(isPreview: false)
    @StateObject var menuViewModel: MenuViewModel = MenuViewModel()
    @Environment(\.colorScheme) var colorScheme
        
    var body: some View {
        NavigationStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Build playlist")
                
                Group {
                    switch menuViewModel.menuStyle {
                    case .list:
                        menuListView
                    case .grid:
                        menuGridView
                    }
                    Spacer()
                }
                .navigationDestination(isPresented: $menuViewModel.shouldNavigate) { destinationView()}
                .foregroundStyle(Theme(colorScheme).textColor)
            }
            .padding()
            .navigationBarBackButtonHidden()
            .toolbar {
                MenuProfileBarView(menuStyle: $menuViewModel.menuStyle)
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
        }
    }
    
    var menuListView: some View {
        VStack {
            ForEach(menuViewModel.menuItems, id: \.self) { menuItem in
                MenuListItemCell(shouldNavigate: $menuViewModel.shouldNavigate, selection: $menuViewModel.selection, menuItem: menuItem)
            }
        }
    }
    
    var menuGridView: some View {
        VStack {
            let columns = [GridItem(.adaptive(minimum: 144))]
            
            LazyVGrid (columns: columns) {
                ForEach(menuViewModel.menuItems, id: \.self) { menuItem in
                    MenuGridItemCell(shouldNavigate: $menuViewModel.shouldNavigate, selection: $menuViewModel.selection, menuItem: menuItem)
                        .padding(12)
                }
            }
        }
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch menuViewModel.selection {
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

#Preview {
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
    
    let artistSingleSearchViewModel = ArtistSingleSearchViewModel(isPreview: true)

    return MenuView(artistSingleSearchViewModel: artistSingleSearchViewModel)
}


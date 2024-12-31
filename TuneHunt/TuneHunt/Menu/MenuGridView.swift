//import SwiftUI
//import Combine
//import SpotifyWebAPI
//
//struct MenuGridView: View {
//    @EnvironmentObject var spotify: Spotify
//    @Environment(\.colorScheme) var colorScheme
//    
//    @State private var profileImage = Image(systemName: "person.crop.circle")
//    @State private var didRequestImage = false
//    @State private var loadImageCancellable: AnyCancellable? = nil
//    @State private var shouldNavigate = false
//    @State private var selection: Int = 0
//    
//    var menuItems: [MenuItem]
//        
//    var body: some View {
//        VStack {
//            let columns = [GridItem(.adaptive(minimum: 144))]
//            
//            LazyVGrid (columns: columns) {
//                ForEach(menuItems, id: \.self) { menuItem in
//                    MenuGridItemCell(shouldNavigate: $shouldNavigate, selection: $selection, menuItem: menuItem)
//                        .padding(12)
//                }
//            }
//            Spacer()
//            
//        }
//        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
//        .foregroundStyle(Theme(colorScheme).textColor)
//    }
//    
//    @ViewBuilder
//    func destinationView() -> some View {
//        switch selection {
//        case 1:
//            ArtistSingleSearchView()
//        case 2:
//            ArtistMultipleSearchView()
//        case 3:
//            ArtistImageSearchView()
//        case 4:
//            PlaylistSearchArtistsView()
//        default:
//            EmptyView()
//        }
//    }
//    
//}
//
//#Preview {
//    let spotify = {
//        let spotify = Spotify()
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    let menuItems = [
//        MenuItem(selection: 1,
//                 imageSystemName: "person",
//                 listItemTitle: "Top tracks from single artist"),
//        MenuItem(selection: 2,
//                 imageSystemName: "person.3",
//                 listItemTitle: "Top tracks from multiple artists"),
//        MenuItem(selection: 3,
//                 imageSystemName: "photo",
//                 listItemTitle: "Find artists from image"),
//        MenuItem(selection: 4,
//                 imageSystemName: "music.note.list",
//                 listItemTitle: "Find artists from other playlist")
//    ]
//    
//    MenuGridView(menuItems: menuItems)
//        .environmentObject(spotify)
//}
//

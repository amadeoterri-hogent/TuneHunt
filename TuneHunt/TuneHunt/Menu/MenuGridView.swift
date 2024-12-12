import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuGridView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var profileImage = Image(systemName: "person.crop.circle")
    @State private var textImage = Image(.recordPlayer)
    @State private var pictureImage = Image(.camera)
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var showInfoText = false
    @State private var showInfoImage = false
    @State private var shouldNavigate = false
    @State private var selection: Int = 0
    
    var menuItems: [MenuItem]
        
    var body: some View {
        VStack {
            let columns = [GridItem(.adaptive(minimum: 150))]
            
            LazyVGrid (columns: columns) {
                ForEach(menuItems, id: \.self) { menuItem in
                    MenuGridItemCell(shouldNavigate: $shouldNavigate, selection: $selection, menuItem: menuItem)
                        .padding(.horizontal,24)
                        .padding(.top,24)
                }
            }
            Spacer()
            
        }
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .foregroundStyle(Theme(colorScheme).textColor)
                
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            EmptyView()
        case 2:
            ArtistTextSearchView(spotify: spotify)
        case 3:
            ArtistImageSearchView(spotify: spotify)
        case 4:
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
    
    MenuGridView(spotify:spotify, menuItems: menuItems)
}


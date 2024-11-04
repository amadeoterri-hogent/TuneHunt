import SwiftUI

struct MenuView: View {
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink(
                    "Create playlist from text", destination: PlayListView()
                    // TODO add info button which collapses an info text
                )
                NavigationLink(
                    "Create playlist from image", destination: PlayListView()
                )
                NavigationLink(
                    "Menu Item 3", destination: PlayListView()
                )
                NavigationLink(
                    "Menu Item 4", destination: PlayListView()
                )
                NavigationLink(
                    "Menu Item 5", destination: PlayListView()
                )
            }
            .listStyle(PlainListStyle())
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        NavigationView {
            MenuView()
                .environmentObject(spotify)
        }
    }
}

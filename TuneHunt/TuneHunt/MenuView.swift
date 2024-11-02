import SwiftUI

struct MenuView: View {
    
    var body: some View {
        List {
            
            NavigationLink(
                "Menu Item 1", destination: PlayListView()
                // TODO add info button which collapses an info text
            )
            NavigationLink(
                "Menu Item 2", destination: PlayListView()
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

import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct MenuProfileBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var spotify: Spotify
    @ObservedObject var menuViewModel: MenuViewModel
    
    var body: some View {
        if spotify.currentUser != nil {
            Menu {
                pkrMenuStyle
                Divider()
                btnSettings
                btnLogOut
            } label: {
                lblProfile
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .foregroundStyle(Theme(colorScheme).textColor)
            .onAppear(perform: menuViewModel.loadProfileImage)
        }
    }
    
    var lblProfile : some View {
        menuViewModel.profileImage
            .resizable()
            .scaledToFit()
            .clipShape(Circle())
            .frame(width: 48, height: 48)
    }
    
    var pkrMenuStyle: some View {
        Picker("Menu layout", selection: $menuViewModel.menuStyle) {
            ForEach(MenuStyle.allCases) { style in
                Label(style.label, systemImage: style.systemImage)
                    .tag(style)
            }
        }
    }
    
    var btnSettings: some View {
        Button {
            menuViewModel.selection = 5
            menuViewModel.shouldNavigate = true
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
    
    var btnLogOut: some View {
        Button (role: .destructive) {
            spotify.api.authorizationManager.deauthorize()
            menuViewModel.selection = 6
            menuViewModel.shouldNavigate = true
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    if let image = URL(string: "https://picsum.photos/200/300") {
        let spotifyImage = SpotifyImage(url: image)
        let demoUser = SpotifyUser(
            displayName: "Amadeo",
            uri: "www.google.com",
            id: "1",
            images: [spotifyImage],
            href: URL(string: "www.google.com")!
        )

        let spotify = {
            let spotify = Spotify.shared
            spotify.isAuthorized = true
            spotify.currentUser = demoUser
            return spotify
        }()
        
        let menuViewModel = MenuViewModel()
        MenuProfileBarView(menuViewModel: menuViewModel)
            .environmentObject(spotify)
    }
    else {
        let spotify = {
            let spotify = Spotify.shared
            spotify.isAuthorized = true
            return spotify
        }()
        
        let menuViewModel = MenuViewModel()
        MenuProfileBarView(menuViewModel: menuViewModel)
    }
}

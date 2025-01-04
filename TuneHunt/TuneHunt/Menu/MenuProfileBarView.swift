import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct MenuProfileBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var menuViewModel: MenuViewModel
    @Binding var menuStyle: MenuStyle
    @Binding var shouldNavigate: Bool
    
    var body: some View {
        if menuViewModel.currentUser() != nil {
            Menu {
                pkrMenuStyle
                Divider()
                btnSettings
                btnLogOut
            } label: {
                lblProfile
            }
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
        Picker("Menu layout", selection: $menuStyle) {
            ForEach(MenuStyle.allCases) { style in
                Label(style.label, systemImage: style.systemImage)
                    .tag(style)
            }
        }
    }
    
    var btnSettings: some View {
        Button {
            menuViewModel.selection = 5
            shouldNavigate = true
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
    
    var btnLogOut: some View {
        Button (role: .destructive) {
            self.menuViewModel.deauthorize()
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                .foregroundStyle(.red)
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
        let spotify = Spotify.shared
        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    
    let menuViewModel: MenuViewModel = MenuViewModel()
    
    MenuProfileBarView(menuViewModel: menuViewModel, menuStyle: .constant(.list), shouldNavigate: .constant(false))
        .environmentObject(spotify)
}

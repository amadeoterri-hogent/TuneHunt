import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct MenuProfileBarView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var menuViewModel: MenuViewModel
    
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
            .frame(width: 64, height: 64)
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
            self.menuViewModel.deauthorize()
            menuViewModel.selection = 6
            menuViewModel.shouldNavigate = true
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                .foregroundStyle(.red)
        }
    }
}

#Preview {
    let menuViewModel: MenuViewModel = MenuViewModel()
    MenuProfileBarView(menuViewModel: menuViewModel)
}

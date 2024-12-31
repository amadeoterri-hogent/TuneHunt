import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct MenuProfileBarView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var menuStyle: MenuStyle
    
    @State private var profileImage = Image(systemName: "person.crop.circle")
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var shouldNavigate = false
    
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
            .foregroundStyle(Theme(colorScheme).textColor)
            .onAppear(perform: loadProfileImage)
            .navigationDestination(isPresented: $shouldNavigate) {
                SettingsView()
            }
        }
    }
    
    var lblProfile : some View {
        profileImage
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
            shouldNavigate = true
        } label: {
            Label("Settings", systemImage: "gear")
        }
    }
    
    var btnLogOut: some View {
        Button (role: .destructive){
            spotify.api.authorizationManager.deauthorize()
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                .foregroundStyle(.red)
        }
    }
    
    func loadProfileImage() {
        guard let spotifyImage = spotify.currentUser?.images?.largest else {
            return
        }
        
        self.loadImageCancellable = spotifyImage.load()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { image in
                    self.profileImage = image
                }
            )
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
    
    MenuProfileBarView(menuStyle: .constant(.list))
        .environmentObject(spotify)
}

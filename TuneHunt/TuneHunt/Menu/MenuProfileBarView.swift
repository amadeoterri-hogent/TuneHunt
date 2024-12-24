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
    
    var body: some View {
        if spotify.currentUser != nil {
            Menu {
                Picker("Menu layout", selection: $menuStyle) {
                    ForEach(MenuStyle.allCases) { style in
                        Label(style.label, systemImage: style.systemImage)
                            .tag(style)
                    }
                }
                
                Divider()
                
                Button {
                
                } label: {
                    Label("Settings", systemImage: "gear")
                }
                
                Button (role: .destructive){
                    spotify.api.authorizationManager.deauthorize()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.forward")
                        .foregroundStyle(.red)
                }
                
            } label: {
                profileImage
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .frame(width: 48, height: 48)
            }
            .foregroundStyle(Theme(colorScheme).textColor)
            .onAppear(perform: loadProfileImage)
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
    
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    
    MenuProfileBarView(menuStyle: .constant(.list))
        .environmentObject(spotify)
}

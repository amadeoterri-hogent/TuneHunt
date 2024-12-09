import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct ProfileBarView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var profileImage = Image(systemName: "person.crop.circle")
    @State private var loadImageCancellable: AnyCancellable? = nil

    var body: some View {
        if let user = spotify.currentUser {
            HStack {
                Button {
                    spotify.api.authorizationManager.deauthorize()
                } label: {
                    profileImage
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)
                }
                .foregroundStyle(Theme(colorScheme).textColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
            .onAppear(perform: loadProfileImage)
        }
        else {
            HStack {
                Button {
                    spotify.api.authorizationManager.deauthorize()
                } label: {
                    profileImage
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .frame(width: 48, height: 48)
                }
                .foregroundStyle(Theme(colorScheme).textColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
            .padding(.bottom)
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
    
    return ProfileBarView(spotify: spotify)
}

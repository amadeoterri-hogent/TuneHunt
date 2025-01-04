import Foundation
import Combine
import SwiftUI
import SpotifyWebAPI

class MenuViewModel: ObservableObject {
    @Published private var model = MenuModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate = false
    @Published var selection: Int = 0
    @Published var menuStyle: MenuStyle = .list
    @Published var profileImage = Image(systemName: "person.crop.circle")

    private let spotify: Spotify = Spotify.shared
    private var loadImageCancellable: AnyCancellable? = nil
        
    var menuItems: [MenuItem] {
        self.model.menuItems
    }
    
    var countries: [Country] {
        self.model.countries
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
    
    func currentUser() -> SpotifyUser? {
        spotify.currentUser
    }
    
    func deauthorize() {
        spotify.api.authorizationManager.deauthorize()
        shouldNavigate = true
    }
    
}

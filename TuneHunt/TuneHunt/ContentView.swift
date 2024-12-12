import SwiftUI
import Combine
import SpotifyWebAPI

struct ContentView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var alert: AlertItem? = nil
    
    var body: some View {
        VStack() {
            if (!spotify.isAuthorized) {
                LoginView()
                    .onOpenURL(perform: handleURL(_:))
            } else {
                MenuView()
            }
        }
        .accentColor(Theme(colorScheme).textColor)
    }
    
    func handleURL(_ url: URL) {
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            self.alert = AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            )
            return
        }
        
        spotify.isRetrievingTokens = true
        
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            self.spotify.isRetrievingTokens = false
            
            if case .failure(let error) = completion {
                let alertTitle: String
                let alertMessage: String
                if let authError = error as? SpotifyAuthorizationError,
                   authError.accessWasDenied {
                    alertTitle = "You denied the authorization request."
                    alertMessage = ""
                }
                else {
                    alertTitle =
                    "Couldn't authorize with your account"
                    alertMessage = error.localizedDescription
                }
                self.alert = AlertItem(
                    title: alertTitle, message: alertMessage
                )
            }
        })
        .store(in: &cancellables)
        
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
    }
}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = false
        return spotify
    }()
    
    return ContentView()
        .environmentObject(spotify)
}

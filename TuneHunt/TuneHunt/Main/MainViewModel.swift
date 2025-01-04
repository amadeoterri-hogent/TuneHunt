import Foundation
import SpotifyWebAPI
import Combine

class MainViewModel: ObservableObject {
    @Published var alertItem: AlertItem? = nil
    
    private let spotify: Spotify = Spotify.shared
    private var cancellables: Set<AnyCancellable> = []
    
    func handleURL(_ url: URL) {
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            self.alertItem = AlertItem(
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
                self.alertItem = AlertItem(
                    title: alertTitle, message: alertMessage
                )
            }
        })
        .store(in: &cancellables)
        
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
    }
    
}

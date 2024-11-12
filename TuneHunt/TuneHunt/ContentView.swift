import SwiftUI
import Combine
import SpotifyWebAPI

struct ContentView: View {
    @State private var path: [Int] = []
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var alert: AlertItem? = nil
    
    var textColor: Color { colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    var body: some View {
        NavigationStack() {
            ZStack {
                LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack {
                    LoginView()
                        .padding()
                    MenuView()
                }
                .onOpenURL(perform: handleURL(_:))
            }
        }
        .accentColor(textColor)

    }
    
    func handleURL(_ url: URL) {
        
        // Validate url
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            self.alert = AlertItem(
                title: "Cannot Handle Redirect",
                message: "Unexpected URL"
            )
            return
        }
        
        // This property is used to display an activity indicator in `LoginView`
        // indicating that the access and refresh tokens are being retrieved.
        spotify.isRetrievingTokens = true
        
        // Complete the authorization process by requesting the access and
        // refresh tokens.
        spotify.api.authorizationManager.requestAccessAndRefreshTokens(
            redirectURIWithQuery: url,
            // This value must be the same as the one used to create the
            // authorization URL. Otherwise, an error will be thrown.
            state: spotify.authorizationState
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            // Whether the request succeeded or not, we need to remove the
            // activity indicator.
            self.spotify.isRetrievingTokens = false
            
            /*
             After the access and refresh tokens are retrieved,
             `SpotifyAPI.authorizationManagerDidChange` will emit a signal,
             causing `Spotify.authorizationManagerDidChange()` to be called,
             which will dismiss the loginView if the app was successfully
             authorized by setting the @Published `Spotify.isAuthorized`
             property to `true`.
             
             The only thing we need to do here is handle the error and show it
             to the user if one was received.
             */
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
        
        // MARK: IMPORTANT: generate a new value for the state parameter after
        // MARK: each authorization request. This ensures an incoming redirect
        // MARK: from Spotify was the result of a request made by this app, and
        // MARK: and not an attacker.
        self.spotify.authorizationState = String.randomURLSafe(length: 128)
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        //        spotify.isAuthorized = false
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        ContentView()
            .environmentObject(spotify)
    }
}

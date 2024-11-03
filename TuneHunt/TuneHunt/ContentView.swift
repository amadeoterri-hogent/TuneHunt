import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var cancellables: Set<AnyCancellable> = []

    var body: some View {
        
        NavigationStack {
            Section {
                Button(action: spotify.authorize) {
                    HStack {
                        Image("spotify logo green")
                            .interpolation(.high)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 32)
                            .padding(12)

                        Text("Sign in with Spotify")
                            .padding(12)
                            .foregroundColor(.black)
                        
                    }
                    .padding()                   // Adds padding inside the button
                    .background(Color.white)     // Button background color
                    .cornerRadius(12)            // Rounded corners
                    .overlay(                    // Border overlay
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                }

            }
            
            NavigationView {
                MenuView()
            }
            
            Text("\(spotify.isAuthorized)")
        }
        .onOpenURL(perform: handleURL(_:))

    }
    
    /**
     Handle the URL that Spotify redirects to after the user Either authorizes
     or denies authorization for the application.

     This method is called by the `onOpenURL(perform:)` view modifier directly
     above.
     */
    func handleURL(_ url: URL) {
        
        // **Always** validate URLs; they offer a potential attack vector into
        // your app.
        guard url.scheme == self.spotify.loginCallbackURL.scheme else {
            print("not handling URL: unexpected scheme: '\(url)'")
//            self.alert = AlertItem(
//                title: "Cannot Handle Redirect",
//                message: "Unexpected URL"
//            )
            return
        }
        
        print("received redirect from Spotify: '\(url)'")
        
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
                print("couldn't retrieve access and refresh tokens:\n\(error)")
//                let alertTitle: String
//                let alertMessage: String
//                if let authError = error as? SpotifyAuthorizationError,
//                   authError.accessWasDenied {
//                    alertTitle = "You Denied The Authorization Request :("
//                    alertMessage = ""
//                }
//                else {
//                    alertTitle =
//                        "Couldn't Authorization With Your Account"
//                    alertMessage = error.localizedDescription
//                }
//                self.alert = AlertItem(
//                    title: alertTitle, message: alertMessage
//                )
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
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        ContentView()
            .environmentObject(spotify)
    }
}

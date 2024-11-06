import SwiftUI
import SpotifyWebAPI

struct LoginView: View {
    @EnvironmentObject var spotify: Spotify
    @State var currentUser: SpotifyUser? = nil
    
    var body: some View {
        if (!spotify.isAuthorized) {
            Button(action: spotify.authorize) {
                HStack {
                    Image("spotify logo green")
                        .interpolation(.high)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 16)
                        .padding(12)
                    
                    Text("Sign in with Spotify")
                        .padding(12)
                        .foregroundColor(.black)
                    
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                )
            }
            
        }
        else {
            // TODO: Profile
            HStack {
                if let userName = currentUser?.displayName {
                    Text("Welcome, \(userName)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Button(action: spotify.api.authorizationManager.deauthorize, label: {
                    Text("Logout")
                })
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        //        spotify.isAuthorized = false
        spotify.isAuthorized = true
        return spotify
    }()
    
    static let user = SpotifyUser(
        displayName: "Amadeo",
        uri: "www.google.com",
        id: "1",
        href: URL(string: "www.google.com")!
    )
    
    static var previews: some View {
        LoginView(currentUser: user)
            .environmentObject(spotify)
    }
}

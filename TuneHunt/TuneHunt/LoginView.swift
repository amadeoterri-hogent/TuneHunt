import SwiftUI
import SpotifyWebAPI

struct LoginView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    
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
                if let userName = spotify.currentUser?.displayName {
                    Text("Welcome, \(userName)")
                        .frame(maxWidth: .infinity, alignment: .leading)

                }
                Button(action: spotify.api.authorizationManager.deauthorize, label: {
                    Text("Logout")
                })
                .buttonStyle(.bordered)
                .background(backgroundColor)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .foregroundStyle(textColor)


            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    
    static let demoUser = SpotifyUser(
        displayName: "Amadeo",
        uri: "www.google.com",
        id: "1",
        href: URL(string: "www.google.com")!
    )
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        //        spotify.isAuthorized = false
        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    

    
    static var previews: some View {
        LoginView()
            .environmentObject(spotify)
    }
}

import SwiftUI
import SpotifyWebAPI

struct LoginView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    
    var body: some View {
            ZStack {
                Image(.login)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()


                VStack {
                    Button {
                        spotify.authorize()
                    } label: {
                        HStack {
                            Image(.spotifyLogoGreen)
                                .resizable()
                                .scaledToFit()
                                .containerRelativeFrame(.horizontal) { size, axis in
                                    size * 0.1
                                }

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
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
        spotify.isAuthorized = false
//        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    

    
    static var previews: some View {
        LoginView(spotify: spotify)
    }
}

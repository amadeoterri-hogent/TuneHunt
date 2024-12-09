import SwiftUI
import SpotifyWebAPI

struct LoginView: View {
    @ObservedObject var spotify: Spotify
    
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

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = false
        return spotify
    }()
    
    return LoginView(spotify: spotify)
}

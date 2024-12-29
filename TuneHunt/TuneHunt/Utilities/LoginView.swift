import SwiftUI
import SpotifyWebAPI

struct LoginView: View {
    @EnvironmentObject var spotify: Spotify

    var body: some View {
        ZStack {
            imgLoginBackground
            btnLogin
        }
    }
    
    var imgLoginBackground: some View {
        Image(.login)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
    
    var btnLogin: some View {
        Button {
            spotify.authorize()
        } label: {
            lblLogin
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
    
    var lblLogin: some View {
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
        

}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = false
        return spotify
    }()
    
    LoginView()
        .environmentObject(spotify)
}

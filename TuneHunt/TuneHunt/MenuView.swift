import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var profileImage = Image(systemName: "person.crop.circle")
    @State private var menuImage = Image(.recordPlayer)
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var showInfoText = true
    @State private var showInfoImage = false
    @State private var selection: Int? = nil
    @State private var shouldNavigate = false
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    
    var body: some View {
        VStack {
            if let user = spotify.currentUser {
                HStack {
                    Button {
                        spotify.api.authorizationManager.deauthorize()
                    } label: {
                        profileImage
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 48, height: 48)
                    }
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)
                }
                .onAppear(perform: loadProfileImage)
            }
            else {
                HStack {
                    Button {
                        spotify.api.authorizationManager.deauthorize()
                    } label: {
                        profileImage
                            .resizable()
                            .scaledToFit()
                            .clipShape(Circle())
                            .frame(width: 48, height: 48)
                    }
                    .foregroundStyle(textColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing)
                }
                .padding(.bottom)
            }
            
            VStack {
                menuImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 300, height: 300)

                Button {
                    selection = 1
                    shouldNavigate = true
                } label: {
                    HStack {
                        Image(systemName: "character.cursor.ibeam" )
                            .font(.title2)
                            .frame(width:48,height: 48)
                        
                        Text("Build from text")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,12)
                        Button {
                            withAnimation {
                                menuImage = Image(.recordPlayer)
                            }
                            showInfoText.toggle()
                            if showInfoImage {
                                withAnimation{
                                    showInfoImage.toggle()
                                }
                            }
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .padding(.trailing, 12)
                        
                        
                    }
                    .padding(12)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                
                if showInfoText {
                    Text("Build a playlist which adds the top tracks of artists of your choice. Easily insert or paste a list of artists, and it will automatically add the top tracks of this artist into your playlist. This makes it a lot easier for you to find and listen to new tunes you like!")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                }
                
                Button {
                    selection = 2
                    shouldNavigate = true
                } label: {
                    HStack {
                        Image(systemName: "photo" )
                            .font(.title2)
                            .frame(width:48,height: 48)
                        Text("Build from image")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,12)
                        Button {
                            withAnimation {
                                menuImage = Image(.camera)
                            }
                            showInfoImage.toggle()
                            if showInfoText {
                                withAnimation{
                                    showInfoText.toggle()
                                }                            }
                        } label: {
                            Image(systemName: "info.circle")
                        }
                        .padding(.trailing, 12)
                        
                        
                    }
                    .padding(12)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if showInfoImage {
                    Text("Build a playlist by simply inserting an image, f.e. of your favorite festival. The app will automatically find the artists in the image and add the top tracks of these artists into your playlist. This way you can easily discover new artists and tunes!")
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading,24)
                        .transition(.asymmetric(insertion: .scale, removal: .opacity))
                }
                Spacer()
            }
            .padding(.top)

        }
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .foregroundStyle(textColor)
        
        // TODO: build from other playlist
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistTextSearchView()
        case 2:
            ArtistImageSearchView(artistSearchResults: [])
        default:
            EmptyView()
        }
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
    
}

struct MenuView_Previews: PreviewProvider {
    static let demoUser = SpotifyUser(
        displayName: "Amadeo",
        uri: "www.google.com",
        id: "1",
        href: URL(string: "www.google.com")!
    )
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        spotify.currentUser = demoUser
        return spotify
    }()
    
    static var previews: some View {
        NavigationStack {
            MenuView()
                .environmentObject(spotify)
        }
    }
}

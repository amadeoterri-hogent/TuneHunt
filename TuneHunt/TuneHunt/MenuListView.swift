import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuListView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var menuImage = Image(.recordPlayer)
    @State private var didRequestImage = false
    @State private var showInfoText = false
    @State private var showInfoImage = false
    @State private var selection: Int? = nil
    @State private var shouldNavigate = false
        
    var body: some View {
            VStack {
//                menuImage
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 300, height: 300)

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
                
                Button {
                    
                } label: {
                    HStack {
                        Image(systemName:"music.note.list")
                            .font(.title2)
                            .frame(width:48,height: 48)
                        Text("Build from existing playlist")
                            .font(.title2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading,12)
                    }
                }
                .padding(12)

                Spacer()
            }
            .padding(.top)
        
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .foregroundStyle(Theme(colorScheme).textColor)
        
        // TODO: build from other playlist
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistTextSearchView(spotify:spotify)
        case 2:
            ArtistImageSearchView(spotify:spotify, artistSearchResults: [])
        default:
            EmptyView()
        }
    }
    
}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    return MenuListView(spotify: spotify)
}

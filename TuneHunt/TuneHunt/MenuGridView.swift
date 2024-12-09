import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuGridView: View {
    @ObservedObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var profileImage = Image(systemName: "person.crop.circle")
    @State private var textImage = Image(.recordPlayer)
    @State private var pictureImage = Image(.camera)
    @State private var didRequestImage = false
    @State private var loadImageCancellable: AnyCancellable? = nil
    @State private var showInfoText = false
    @State private var showInfoImage = false
    @State private var selection: Int? = nil
    @State private var shouldNavigate = false
        
    var body: some View {
        VStack {
            let columns = [GridItem(.adaptive(minimum: 150))]
            
            LazyVGrid (columns: columns){
                VStack {
                    Button {
                        selection = 1
                        shouldNavigate = true
                    } label: {
                        VStack {
                            Image(systemName: "character.cursor.ibeam" )
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .padding()

                            HStack {
                                Text("Create playlist from text")
                                    .font(.title2)
                            }
                        }
                        
                    }
                }
                .padding()
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme(colorScheme).textColor)
                )
                
                VStack {
                    Button {
                        selection = 2
                        shouldNavigate = true
                    } label: {
                        VStack {
                            Image(systemName: "photo" )
                                .resizable()
                                .scaledToFill()
                                .frame(width: 48, height: 48)
                                .padding()
                            
                            HStack {
                                Text("Create playlist from image")
                                    .font(.title2)
                                    .foregroundStyle(Theme(colorScheme).textColor)
                            }
                        }
                    }
                }
                .padding()
                .clipShape(.rect(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme(colorScheme).textColor)
                )
            }
            .padding(.top)
            Spacer()
            
        }
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .foregroundStyle(Theme(colorScheme).textColor)
                
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistTextSearchView(spotify: spotify)
        case 2:
            ArtistImageSearchView(spotify: spotify, artistSearchResults: [])
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
    
    return MenuGridView(spotify:spotify)
}


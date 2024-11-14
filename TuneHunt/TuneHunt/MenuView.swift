import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showInfoText = false
    @State private var showInfoImage = false
    @State private var selection: Int? = nil
    @State private var shouldNavigate = false

    var textColor: Color {colorScheme == .dark ? .white : .black}
    
    
    var body: some View {
            VStack {
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
                        Button(action: { showInfoText.toggle()
                            if showInfoImage {
                                showInfoImage.toggle()
                            }
                        }) {
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
                        Button(action: {
                            showInfoImage.toggle()
                            if showInfoText {
                                showInfoText.toggle()
                            }
                        }) {
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
                }
                Spacer()
            }
            .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
            .foregroundStyle(textColor)

    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistTextSearchView()
        case 2:
            ArtistImageSearchView()
        default:
            EmptyView()
        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        NavigationStack {
            MenuView()
                .environmentObject(spotify)
        }
    }
}

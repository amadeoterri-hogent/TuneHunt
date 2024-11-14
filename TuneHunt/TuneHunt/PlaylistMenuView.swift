import SwiftUI
import Combine
import SpotifyWebAPI

struct PlaylistMenuView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var spotify: Spotify
    
    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    
    @State var artists: [Artist] = []
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    
    var body: some View {
        VStack {
            Button {
                selection = 1
                shouldNavigate = true
            } label: {
                HStack {
                    Image(systemName: "plus" )
                        .font(.largeTitle)
                        .frame(width:48,height: 48)
                    VStack {
                        Text("Create playlist")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text("Build a new playlist with songs")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                    
                }
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Button {
                selection = 2
                shouldNavigate = true
            } label:
            {
                HStack {
                    Image(systemName: "music.note.list" )
                        .font(.largeTitle)
                        .frame(width:48,height: 48)
                    VStack {
                        Text("Select playlist")
                            .font(.largeTitle)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Select an existing playlist from your library")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding(EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 0))
                }
                .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
        }
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
        .foregroundStyle(textColor)
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()
        }
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            PlaylistCreateView()
        case 2:
            PlaylistSelectView()
        default:
            EmptyView()
        }
    }
}

extension ProcessInfo {
    
    /// Whether or not this process is running within the context of a SwiftUI
    /// preview.
    var isPreviewing: Bool {
        return self.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
}

struct PlaylistMenuView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        PlaylistMenuView()
            .environmentObject(spotify)
    }
}

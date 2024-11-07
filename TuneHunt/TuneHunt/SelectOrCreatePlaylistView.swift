import SwiftUI
import Combine
import SpotifyWebAPI

struct SelectOrCreatePlaylistView: View {
    @EnvironmentObject var spotify: Spotify
    @State private var createPlaylistCancellable: AnyCancellable?
    @State private var namePlaylist: String = ""
    @State private var alert: AlertItem? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                    NavigationLink(destination: PlaylistCreateView()) {
                        HStack {
                            Image(systemName: "plus" )
                                .font(.largeTitle)
                            VStack {
                                Text("Create playlist")
                                    .font(.largeTitle)
                                Text("Build a playlist with songs")
                                    .font(.subheadline)
                            }

                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)


                NavigationLink(destination: PlaylistSelectView()) {
                    HStack {
                        Image(systemName: "music.note.list" )
                            .font(.largeTitle)
                        VStack {
                            Text("Select playlist")
                                .font(.largeTitle)
                            Text("Select an existing playlist")
                                .font(.subheadline)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()
                
            }
            .navigationTitle("Playlists")
            .padding()

            
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

struct SelectOrCreatePlaylistView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static var previews: some View {
        SelectOrCreatePlaylistView()
            .environmentObject(spotify)
    }
}

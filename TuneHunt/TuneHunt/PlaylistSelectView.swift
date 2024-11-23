import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import SpotifyExampleContent


struct PlaylistSelectView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var alert: AlertItem? = nil
    @State var playlists: [Playlist<PlaylistItemsReference>] = []
    @State private var cancellables: Set<AnyCancellable> = []
    @State private var isLoadingPlaylists = false
    @State private var couldntLoadPlaylists = false
    @State var selectedArtists: [Artist]
    @State private var showingAlert = false
    @State private var shouldNavigate = false
    @State private var selection: Int? = nil
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    var body: some View {
        VStack {
            
            List {
                ForEach(playlists, id: \.uri) { playlist in
                    PlaylistCellView(playlist: playlist,selectedArtists: selectedArtists)
                }
                
            }
            .scrollContentBackground(.hidden)
            
        }
        .background(
            LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
        .foregroundStyle(textColor)
        .navigationDestination(isPresented: $shouldNavigate) {
            destinationView()
        }
        .onAppear(perform: retrievePlaylists)
        .alert(item: $alert) { alert in
            Alert(title: alert.title, message: alert.message)
        }
        .navigationTitle("Your Playlists")
        .toolbar {
            Button {
                selection = 1
                shouldNavigate = true
            } label: {
                Image(systemName: "plus" )
                    .font(.title2)
                    .frame(width:48,height: 48)
                    .foregroundStyle(textColor)
            }
        }
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            PlaylistCreateView(artists: selectedArtists)
        default:
            EmptyView()
        }
    }
    
    
    func retrievePlaylists() {
        self.isLoadingPlaylists = true
        self.playlists = []
        
        spotify.api.currentUserPlaylists(limit: 50)
        // Gets all pages of playlists.
            .extendPages(spotify.api)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { completion in
                    self.isLoadingPlaylists = false
                    switch completion {
                    case .finished:
                        self.couldntLoadPlaylists = false
                    case .failure(let error):
                        self.couldntLoadPlaylists = true
                        self.alert = AlertItem(
                            title: "Couldn't Retrieve Playlists",
                            message: error.localizedDescription
                        )
                    }
                },
                receiveValue: { playlistsPage in
                    let playlists = playlistsPage.items
                    self.playlists.append(contentsOf: playlists)
                }
            )
            .store(in: &cancellables)
        
    }
    
    
    
}

struct PlayListSelectView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    static let playlists: [Playlist<PlaylistItemsReference>] = [
        .menITrust, .modernPsychedelia, .menITrust,
        .lucyInTheSkyWithDiamonds, .rockClassics,
        .thisIsMFDoom, .thisIsSonicYouth, .thisIsMildHighClub,
        .thisIsSkinshape
    ]
    
    @State static var artists = [
        Artist(name: "Pink Floyd"),
        Artist(name: "Radiohead")
    ]
    
    static var previews: some View {
        PlaylistSelectView(playlists: playlists, selectedArtists: artists)
            .environmentObject(spotify)
    }
}

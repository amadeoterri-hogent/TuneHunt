import SpotifyWebAPI
import SwiftUI

struct PlaylistModel<Items: Codable & Hashable>  {
    var userPlaylists: [UserPlaylist] = []
    var selectedPlaylist: Playlist<PlaylistItems>? = nil
    var tracks: [Track] = []
    var artists: [Artist] = []
    
    init() {}
    
    init(userPlaylists: [UserPlaylist]) {
        self.userPlaylists = userPlaylists
    }
    
    mutating func setArtists(_ artists: [Artist]) {
        self.artists = artists
    }
    
    mutating func addPlaylist(playlist: Playlist<Items>) {
        self.userPlaylists.insert(UserPlaylist(playlist: playlist), at: 0)
    }
    
    mutating func addPlaylists(playlists: [Playlist<Items>]) {
        for playlist in playlists {
            self.userPlaylists.append(UserPlaylist(playlist: playlist))
        }
    }
    
    mutating func setUserPlaylists(_ playlists: [UserPlaylist]) {
        self.userPlaylists = playlists
    }
    
    mutating func removeDuplicatesFromTracks() {
        self.tracks = self.tracks.removingDuplicates()
    }
    
    mutating func addTrack(track: Track) {
        if !self.tracks.contains(where: { $0.id == track.id }) {
            self.tracks.append(track)
        }
    }
    
    mutating func updateImageOfUserPlaylist(_ playlist: UserPlaylist, image: Image?) {
        if let index = self.userPlaylists.firstIndex(where: { $0.id == playlist.id }) {
            self.userPlaylists[index].updateImage(image)
        }
    }
    
    mutating func clearTracks() {
        self.tracks = []
    }
    
    struct UserPlaylist {
        var id: String
        var playlist: Playlist<Items>
        var image: Image? = nil {
            didSet {
                print("Image set for userplaylist with name: \(playlist.name)")
            }
        }
        
        init(playlist: Playlist<Items>) {
            self.id = playlist.id
            self.playlist = playlist
        }

        mutating func updateImage(_ image: Image?) {
            self.image = image
        }
    }
}

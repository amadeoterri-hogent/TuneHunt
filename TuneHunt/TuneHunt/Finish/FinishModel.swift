import Foundation
import SpotifyWebAPI
import SwiftUI

struct FinishModel<Items: Codable & Hashable>  {
    private(set) var selectedPlaylist: PlaylistModel<Items>.UserPlaylist? = nil
    private(set) var trackResults: [TrackResult] = []
    
    init() {}
    
    init(selectedPlaylist: PlaylistModel<Items>.UserPlaylist?, trackResults: [TrackResult]) {
        self.selectedPlaylist = selectedPlaylist
        self.trackResults = trackResults
    }
    
    mutating func updateImageOfTrackResult(for trackResult: TrackResult, image: Image?) {
        if let index = trackResults.firstIndex(where: { $0.id == trackResult.id }) {
            trackResults[index].updateImage(image)
        }
    }
    
    mutating func setTracks(_ tracks: [Track]) {
        self.trackResults = tracks.map { TrackResult(track: $0) }
    }
    
    mutating func setSelectedPlaylist(_ userPlaylist: PlaylistModel<Items>.UserPlaylist) {
        self.selectedPlaylist = userPlaylist
    }
    
    func getTracksFromTrackResults() -> [Track] {
        self.trackResults
            .map { $0.track }
    }
    
    struct TrackResult {
        var id: String?
        var track: Track
        var image: Image? = nil
        
        init(track: Track) {
            self.id = track.id
            self.track = track
        }
        
        mutating func updateImage(_ image: Image?) {
            self.image = image
        }
    }
    
}

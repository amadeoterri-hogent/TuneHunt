import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import PhotosUI
import Vision
import NaturalLanguage

struct ArtistImageSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @Environment(\.colorScheme) var colorScheme
    
    @State private var searchText: String = "Recognized text will appear here"
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imagePreview: Image?
    @State private var artistsPreview: [String] = []
    @State private var isProcessingImage = false
    @State private var shouldNavigate = false
    @State private var artistSearchResults: [ArtistSearchResult] = []
    @State private var selection: Int? = nil
    @State private var searchCancellables: [AnyCancellable] = []
    @State private var alertItem: AlertItem? = nil
    @State private var selectedSeparator = "Comma"
    
    var textColor: Color {colorScheme == .dark ? .white : .black}
    var backgroundColor: Color {colorScheme == .dark ? .black : .white}
    
    init(artistSearchResults: [ArtistSearchResult]) {
        self.artistSearchResults = artistSearchResults
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    // Image Picker
                    PhotosPicker("Select a Picture", selection: $pickerItem, matching: .images)
                } header: {
                    Text("Choose a picture from your photo album")
                }
                
                Section {
                    
                    // Show Selected Image
                    if let imagePreview = imagePreview {
                        imagePreview
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .padding()
                    }
                    
                    // Loading Indicator
                    if isProcessingImage {
                        ProgressView("Processing image...")
                            .padding()
                    }
                    
                    // Extracted Artist List
                    if !artistsPreview.isEmpty {
                        ScrollView {
                            
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(artistsPreview, id: \.self) { artist in
                                    HStack {
                                        Text(artist)
                                        Button(action: { removeArtist(artist) }) {
                                            Image(systemName: "minus.circle")
                                        }
                                    }
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 8)
                                    .background(Color(UIColor.systemGray5))
                                    .cornerRadius(5)
                                    
                                }
                                
                            }
                        }
                    }
                    
                }
                Section {
                    
                    Button {
                        selection = 1
                        searchArtists()
                    } label: {
                        Text("Search")
                    }
                } header: {
                    Text("Search artists in spotify")
                }
                
            }
            .scrollContentBackground(.hidden)
        }
        .navigationDestination(isPresented: $shouldNavigate) { destinationView()}
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LinearGradient(colors: [.blue, backgroundColor], startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea())
        .onChange(of: pickerItem, initial: true) {
            processPickerItem()
        }
        
    }
    
    @ViewBuilder
    func destinationView() -> some View {
        switch selection {
        case 1:
            ArtistSearchResultsListView(artistsSearchResults: artistSearchResults)
        default:
            EmptyView()
        }
    }
    
    private func processPickerItem() {
        Task {
            guard let data = try? await pickerItem?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            
            // Set image preview and perform text recognition
            selectedImage = uiImage
            imagePreview = Image(uiImage: uiImage)
            searchText = ""
            artistsPreview = []
            performTextRecognition(on: uiImage)
        }
    }
    
    private func performTextRecognition(on image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        isProcessingImage = true
        let request = VNRecognizeTextRequest { request, error in
            defer { isProcessingImage = false }
            
            if let error = error {
                print("Text recognition error: \(error)")
                DispatchQueue.main.async {
                    self.searchText = "Error recognizing text: \(error.localizedDescription)"
                }
                return
            }
            
            // Process recognized text
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                DispatchQueue.main.async {
                    self.searchText = recognizedStrings.joined(separator: ",")
                    self.artistsPreview = Array(searchText
                        .split(separator: " ")
                        .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .removingDuplicates()
                                                //                         TODO: remove filter first 10 results and filter with ai possibly
                        .prefix(30)
                    )
                }
            }
        }
        
        // Configure the request
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                print("Failed to perform text recognition: \(error)")
                DispatchQueue.main.async {
                    self.searchText = "Error processing image: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func searchArtists() {
        self.artistSearchResults = []
        let artistNames = artistsPreview
        guard !artistNames.isEmpty else {
            // TODO: alert
            return
        }
        
        var remainingSearches = artistNames.count
        for artist in artistNames {
            let cancellable = spotify.api.search(
                query: artist, categories: [.artist]
            )
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        remainingSearches -= 1
                        if remainingSearches == 0 {
                            self.shouldNavigate = true
                        }
                        if case .failure(let error) = completion {
                            self.alertItem = AlertItem(
                                title: "Couldn't Perform Search",
                                message: error.localizedDescription
                            )
                        }
                    },
                    receiveValue: { searchResults in
                        if let artist = searchResults.artists?.items.first {
                            print("Add artist: \(artist.name)")
                            self.artistSearchResults.append(ArtistSearchResult(artist: artist))
                        }
                    }
                )
            self.searchCancellables.append(cancellable)
        }
    }
    
    private func splitArtists() -> Void {
        let separator: Character = ","
        artistsPreview = searchText
            .split(separator: separator)
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .removingDuplicates()
    }
    
    private func removeArtist(_ artist: String) {
        artistsPreview.removeAll { $0 == artist }
    }
}

struct ArtistImageSearchView_Previews: PreviewProvider {
    
    static let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    static let artists = [
        ArtistSearchResult(artist: .pinkFloyd),
        ArtistSearchResult(artist: .radiohead)
    ]
    
    static var previews: some View {
        ArtistImageSearchView(artistSearchResults: artists)
            .environmentObject(spotify)
    }
}

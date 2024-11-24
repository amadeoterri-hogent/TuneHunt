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
    
    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var imagePreview: Image?
    @State private var artists: [String] = []
    @State private var imageUploaded = false
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
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Upload an image")
                            }
                        }
                        .foregroundStyle(textColor)
                        .padding()
                        .background(.blue)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }
                .listRowBackground(Color.clear)

                // TODO: Loading screen
                if imageUploaded {
                    Section {
                        
                        if let imagePreview = imagePreview {
                            imagePreview
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                    .listRowBackground(Color.clear)
                    Section {
                        // Extracted Artist List
                        if artists.isEmpty {
                            Text("No artists found.")
                        } else {
                            List {
                                ForEach(artists, id: \.self) {
                                    Text("\($0)")
                                }
                                .onDelete(perform: removeArtist)
                            }
                        }
                    } header: {
                        Text("Result:")
                    }
                    
                    Section {
                        Button {
                            selection = 1
                            searchArtists()
                        } label: {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Search artists in Spotify")
                                
                            }
                            
                        }
                        .foregroundStyle(textColor)
                        .padding()
                        .background(.green)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.clear)
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
        .alert(item: $alertItem) { alert in
            Alert(title: alert.title, message: alert.message)
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
            artists = []
            performTextRecognition(on: uiImage)
        }
    }
    
    private func performTextRecognition(on image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        
        let request = VNRecognizeTextRequest { request, error in
            defer { imageUploaded = true }
            
            if let error = error {
                print("Text recognition error: \(error)")
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(
                        title: "Couldn't Perform Search",
                        message: "No artists where found."
                    )
                }
                return
            }
            
            // Process recognized text
            if let observations = request.results as? [VNRecognizedTextObservation] {
                let recognizedStrings = observations.compactMap { $0.topCandidates(1).first?.string }
                DispatchQueue.main.async {
                    self.artists = Array(
                        recognizedStrings
                            .joined(separator: " ")
                            .replacingOccurrences(of: "•", with: ",")
                            .replacingOccurrences(of: "-", with: ",")
                            .replacingOccurrences(of: "  ", with: " ")
//                            .components(separatedBy: [",", "\n"]
                            .components(separatedBy: CharacterSet(charactersIn: ",\n"))
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                            .filter { !$0.isEmpty }
                            .removingDuplicates()
                    )
                    print(artists)
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
                    self.alertItem = AlertItem(
                        title: "Couldn't Perform Search",
                        message: "No artists where found."
                    )
                }
            }
        }
    }
    
    func searchArtists() {
        self.artistSearchResults = []
        let artistNames = artists
        guard !artistNames.isEmpty else {
            self.alertItem = AlertItem(
                title: "Couldn't Perform Search",
                message: "No artists where found."
            )
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
    
    private func removeArtist(at offsets: IndexSet) {
        withAnimation {
            artists.remove(atOffsets: offsets)
        }
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

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
    
    @State private var pickerItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var imagePreview: Image? = nil
    @State private var artists: [String] = []
    @State private var imageUploaded = false
    @State private var shouldNavigate = false
    @State private var artistSearchResults: [ArtistSearchResult] = []
    @State private var searchCancellables: [AnyCancellable] = []
    @State private var alertItem: AlertItem? = nil
    @State private var searching: Bool = false
    @State private var loading: Bool = false
    @State private var selectedSeparator = "Comma"
    
    var body: some View {
        ZStack {
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
                        .foregroundStyle(Theme(colorScheme).textColor)
                        .padding()
                        .background(.blue)
                        .clipShape(Capsule())
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .listRowBackground(Color.clear)
                    
                    if imageUploaded {
                        Section {
                            if let imagePreview = imagePreview {
                                imagePreview
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width:200, height: 400)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }
                        }
                        .listRowBackground(Color.clear)
                        
                        Section {
                            Button {
                                searchArtists()
                            } label: {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                    Text("Search artists in Spotify")
                                }
                            }
                            .foregroundStyle(Theme(colorScheme).textColor)
                            .padding()
                            .background(.green)
                            .clipShape(Capsule())
                            .frame(maxWidth: .infinity, alignment: .center)
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
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationDestination(isPresented: $shouldNavigate) {
                ArtistSearchResultsListView(artistsSearchResults: artistSearchResults)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .onChange(of: pickerItem, initial: true) {
                processPickerItem()
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            
            if searching {
                ProgressView("Searching...", value: Double(artistSearchResults.count), total: Double(artists.count))
                    .progressViewStyle(.circular)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
            
            if loading {
                ProgressView("Loading data...")
                    .progressViewStyle(.circular)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 10)
            }
        }
    }
    
    private func processPickerItem() {
        Task {
            guard let data = try? await pickerItem?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            
            self.loading = true
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
                    print(self.artists)
                }
            }
        }
        
        // Configure the request
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
                self.loading = false
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
        
        self.searching = true
        var remainingSearches = Double(artistNames.count)
        
        for artist in artistNames {
            let cancellable = spotify.api.search(
                query: artist, categories: [.artist]
            )
                .receive(on: RunLoop.main)
                .sink(
                    receiveCompletion: { completion in
                        remainingSearches -= 1
                        if remainingSearches == 0 {
                            self.searching = false
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
                            // Check for duplicates after search
                            if !self.artistSearchResults.contains(where: { $0.artist.id == artist.id }) {
                                self.artistSearchResults.append(ArtistSearchResult(artist: artist))
                            }
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

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()
    
    ArtistImageSearchView()
        .environmentObject(spotify)
}

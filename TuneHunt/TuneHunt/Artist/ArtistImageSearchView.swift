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
    @State private var shouldNavigate = false
    @State private var alertItem: AlertItem? = nil
    @State private var loading: Bool = false
    
    @State var selectedImage: UIImage? = nil
    @State var imageUploaded = false
    @State var imagePreview: Image? = nil
    @State var searchText: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Text("Select Image")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Upload an image")

                        }
                        .frame(maxWidth: .infinity)
                    }
                    .foregroundStyle(Theme(colorScheme).textColor)
                    .padding()
                    .background(.blue)
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    Text("Tap the image to extract text from image")
                        .font(.caption2)
                        .foregroundColor(Theme(colorScheme).textColor)
                        .opacity(0.4)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    if imageUploaded {
                        VStack {
                            if let imagePreview = imagePreview {
                                imagePreview
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:280, height: 480)
                                    .shadow(radius: 12)
                                    .cornerRadius(12)
                                    .padding(24)
                                    .onTapGesture {
                                        if let image = selectedImage {
                                            self.loading = true
                                            self.performTextRecognition(on: image)
                                        }
                                    }
                            }
                        }
                        .padding(.vertical)
                    }
                    else {
                        Text("No image")
                            .frame(maxHeight: .infinity, alignment: .center)
                            .foregroundColor(Theme(colorScheme).textColor)
                            .font(.title)
                            .opacity(0.6)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 48)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .navigationDestination(isPresented: $shouldNavigate) {
                ArtistMultipleSearchView(searchText: searchText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .onChange(of: pickerItem, initial: false) {
                processPickerItem()
            }
            .alert(item: $alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            
            if loading {
                ProgressView("Loading...")
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
            self.loading = true
            guard let data = try? await pickerItem?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            self.selectedImage = uiImage
            self.imagePreview = Image(uiImage: uiImage)
            self.imageUploaded = true
            self.loading = false
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
                    self.searchText = recognizedStrings
                        .joined(separator: " ")
                        .replacingOccurrences(of: "•", with: ",")
                        .replacingOccurrences(of: "-", with: ",")
                        .replacingOccurrences(of: "  ", with: " ")
                        .components(separatedBy: CharacterSet(charactersIn: ",\n"))
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: ",")
                    
                    print(self.searchText)
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
                self.shouldNavigate = true
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
}

//#Preview {
//    let spotify: Spotify = {
//        let spotify = Spotify()
//        spotify.isAuthorized = true
//        return spotify
//    }()
//    
//    ArtistImageSearchView()
//        .environmentObject(spotify)
//}

#Preview {
    let spotify: Spotify = {
        let spotify = Spotify()
        spotify.isAuthorized = true
        return spotify
    }()

    let selectedImage = UIImage(resource: .recordPlayer)
    let imageUploaded = true
    let imagePreview = Image(uiImage: selectedImage)

    ArtistImageSearchView(selectedImage: selectedImage, imageUploaded: imageUploaded, imagePreview: imagePreview)
        .environmentObject(spotify)
}

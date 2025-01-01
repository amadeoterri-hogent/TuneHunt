import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import PhotosUI
import Vision
import NaturalLanguage

class SearchArtistImageViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var imageUploaded = false
    @Published var shouldNavigate = false
    @Published var alertItem: AlertItem? = nil
    @Published var imagePreview: Image? = nil
    @Published var pickerItem: PhotosPickerItem? = nil
    @Published var selectedImage: UIImage? = nil
    
    init() {}
    
    init(selectedImage: UIImage?, imageUploaded: Bool, imagePreview: Image?) {
        self.selectedImage = selectedImage
        self.imageUploaded = imageUploaded
        self.imagePreview = imagePreview
    }
    
    func processPickerItem() {
        self.isLoading = true
        
        Task {
            guard let data = try? await self.pickerItem?.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else { return }
            
            await MainActor.run {
                self.selectedImage = uiImage
                self.imagePreview = Image(uiImage: uiImage)
                self.imageUploaded = true
                self.isLoading = false
            }
        }
    }
    
    func performTextRecognition(searchArtistViewModel: SearchArtistViewModel) {
        guard let image = self.selectedImage else { return }
        guard let cgImage = image.cgImage else { return }
        
        self.isLoading = true
        
        let request = VNRecognizeTextRequest { request, error in
            
            if let error = error {
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
                    let searchText = recognizedStrings
                        .joined(separator: " ")
                        .replacingOccurrences(of: "•", with: ",")
                        .replacingOccurrences(of: "-", with: ",")
                        .replacingOccurrences(of: "  ", with: " ")
                        .components(separatedBy: CharacterSet(charactersIn: ",\n"))
                        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        .filter { !$0.isEmpty }
                        .joined(separator: ",")
                    searchArtistViewModel.searchText = searchText
                    self.isLoading = false
                    self.shouldNavigate = true
                }
            } else {
                self.isLoading = false
                return
            }
        }
        
        // Configure the request
        request.recognitionLevel = .accurate
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try requestHandler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.alertItem = AlertItem(
                        title: "Couldn't Perform Search",
                        message: "No artists where found."
                    )
                    self.isLoading = false
                    return
                }
            }
        }
    }
}

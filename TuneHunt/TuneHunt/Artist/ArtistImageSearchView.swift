import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI
import PhotosUI
import Vision
import NaturalLanguage

struct ArtistImageSearchView: View {
    @ObservedObject var searchArtistViewModel: ArtistSearchViewModel
    @StateObject var searchArtistImageViewModel = ArtistImageSearchViewModel()
    @Environment(\.colorScheme) var colorScheme
            
    var body: some View {
        ZStack {
            VStack {
                DefaultNavigationTitleView(titleText: "Select Image")
                btnUploadImage
                DefaultCaption(captionText: "Tap the image to extract text from image")

                if searchArtistImageViewModel.imageUploaded {
                    imgPreview
                } else {
                    txtNoImage
                }
                
                Spacer()
            }
            .padding()
            .navigationDestination(isPresented: $searchArtistImageViewModel.shouldNavigate) {
                ArtistMultipleSearchView(searchArtistViewModel: searchArtistViewModel)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea())
            .onChange(of: searchArtistImageViewModel.pickerItem, initial: false) {
                searchArtistImageViewModel.processPickerItem()
            }
            .alert(item: $searchArtistImageViewModel.alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            
            if searchArtistImageViewModel.isLoading {
                DefaultProgressView(progressViewText: "Loading...")
            }
        }
    }
    
    var btnUploadImage: some View {
        PhotosPicker(selection: $searchArtistImageViewModel.pickerItem, matching: .images) {
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
    }
    
    var imgPreview: some View {
        Group {
            if let imgUploadedImagePreview = searchArtistImageViewModel.imagePreview {
                imgUploadedImagePreview
                    .resizable()
                    .scaledToFit()
                    .frame(width: 280, height: 480)
                    .shadow(radius: 12)
                    .cornerRadius(12)
                    .padding(24)
                    .onTapGesture {
                        if searchArtistImageViewModel.selectedImage != nil {
                            searchArtistImageViewModel.performTextRecognition(searchArtistViewModel: searchArtistViewModel)
                        }
                    }
            }
        }
    }
    
    var txtNoImage: some View {
        Text("No image")
            .frame(maxHeight: .infinity, alignment: .center)
            .foregroundColor(Theme(colorScheme).textColor)
            .font(.title)
            .opacity(0.6)
            .foregroundColor(.secondary)
            .padding(.bottom, 48)
    }
}

#Preview {
    let selectedImage = UIImage(resource: .recordPlayer)
    let imageUploaded = true
    let imagePreview = Image(uiImage: selectedImage)
    let searchArtistImageViewModel = ArtistImageSearchViewModel(selectedImage: selectedImage, imageUploaded: imageUploaded, imagePreview: imagePreview)
    let searchArtistViewModel = ArtistSearchViewModel()

    ArtistImageSearchView(searchArtistViewModel: searchArtistViewModel, searchArtistImageViewModel: searchArtistImageViewModel)
}

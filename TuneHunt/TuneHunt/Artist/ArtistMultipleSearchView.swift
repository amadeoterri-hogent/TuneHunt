import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct ArtistMultipleSearchView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var searchArtistViewModel: ArtistSearchViewModel
    @StateObject var artistSearchResultViewModel = ArtistSearchResultViewModel()
    
    @FocusState private var searchTextIsFocused: Bool
        
    let pasteboard = UIPasteboard.general
        
    var body: some View {
        ZStack {
            ZStack {
                Color.clear
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        searchTextIsFocused = false
                    }
                
                ScrollView {
                    VStack {
                        DefaultNavigationTitleView(titleText: "Enter artists")
                        btnSearchSpotify
                    }
                    .onTapGesture {
                        searchTextIsFocused = false
                    }

                    txtEditor
                }
                .scrollIndicators(.hidden)
                .padding()

            }
            .toolbar {
                toolBar
            }
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $searchArtistViewModel.shouldNavigate) {
                ArtistSearchResultsListView(artistSearchResultViewModel: artistSearchResultViewModel)
            }
            .alert(item: $searchArtistViewModel.alertItem) { alert in
                Alert(title: alert.title, message: alert.message)
            }
            .sheet(isPresented: $searchArtistViewModel.showArtistsPreview, onDismiss: {searchArtistViewModel.showArtistsPreview = false} ) {
                ArtistPreviewView(artists: $searchArtistViewModel.artistsPreview)
            }
                       
            if searchArtistViewModel.isSearching {
                DefaultProgressView(progressViewText: "Searching...")
            }
        }
    }
    
    var btnSearchSpotify: some View {
        Button {
            searchArtistViewModel.searchMultipleArtists(artistSearchResultViewModel: artistSearchResultViewModel)
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search artists in Spotify")
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(searchArtistViewModel.isSearching)
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding()
        .background(.blue)
        .clipShape(Capsule())
    }
    
    var txtEditor: some View {
        TextEditor(text: $searchArtistViewModel.searchText)
            .contentMargins(12)
            .focused($searchTextIsFocused)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .frame(height: 320)
            .cornerRadius(12)
            .onChange(of: searchArtistViewModel.searchText, initial: true) {
                searchArtistViewModel.splitArtists()
            }
            .padding(.top, 24)
    }
    
    /// Toolbar: Start
    var toolBar: some View {
        Menu {
            btnToolBarPreview
            btnToolBarPasteFromClipboard
            btnToolBarClearText
        }
        label: {
            Image(systemName: "ellipsis.circle")
        }
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    var btnToolBarPreview: some View {
        Button {
            searchArtistViewModel.showArtistsPreview = true
        } label: {
            HStack {
                Image(systemName: "eye")
                Text("Preview")
            }
        }
    }
    
    var btnToolBarPasteFromClipboard: some View {
        Button {
            if let textFromPasteboard = pasteboard.string {
                searchArtistViewModel.searchText.append(textFromPasteboard)
            }
        } label: {
            HStack {
                Image(systemName: "list.clipboard")
                Text("Paste from clipboard")
            }
        }
    }
    
    var btnToolBarClearText: some View {
        Button {
            searchArtistViewModel.clear()
        } label: {
            HStack {
                Image(systemName: "clear")
                Text("Clear text")
            }
        }
    }
    
    var pkrToolBarArtistsSeparator: some View {
        Picker("Separator", selection: $searchArtistViewModel.selectedSeparator) {
            ForEach(searchArtistViewModel.separators, id: \.self) {
                Text($0)
            }
        }
        .pickerStyle(.menu)
        .onChange(of: searchArtistViewModel.selectedSeparator, initial: false) {
            searchArtistViewModel.splitArtists()
        }
    }
    /// Toolbar: End
    
    private func removeArtist(at offsets: IndexSet) {
        withAnimation {
            searchArtistViewModel.removeArtist(at: offsets)
        }
    }
    
}

#Preview {
    let searchArtistViewModel = ArtistSearchViewModel()
    ArtistMultipleSearchView(searchArtistViewModel: searchArtistViewModel)
}



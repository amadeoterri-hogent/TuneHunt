import SwiftUI
import Combine
import Foundation
import SpotifyWebAPI

struct ArtistMultipleSearchView: View {
    @EnvironmentObject var spotify: Spotify
    @ObservedObject var searchArtistViewModel: SearchArtistViewModel
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var searchTextIsFocused: Bool
        
    let pasteboard = UIPasteboard.general
        
    var body: some View {
        ZStack {
                ZStack {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            searchTextIsFocused = false
                        }
                    VStack {
                        DefaultNavigationTitleView(titleText: "Enter artists")
                        ScrollView {
                            btnSearchSpotify
                            txtEditor
                        }
                    }
                
            }
            .toolbar {
                toolBar
            }
            .padding()
            .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            )
            .navigationDestination(isPresented: $searchArtistViewModel.shouldNavigate) {
                ArtistSearchResultsListView(artistsSearchResults: searchArtistViewModel.artistSearchResults)
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
            searchArtistViewModel.searchMultipleArtists()
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("Search artists in Spotify")
            }
            .frame(maxWidth: .infinity)
        }
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
            .frame(height: 480)
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
    let spotify = {
        let spotify = Spotify.shared
        spotify.isAuthorized = true
        return spotify
    }()
    
    let searchArtistViewModel = SearchArtistViewModel()
    
    ArtistMultipleSearchView(searchArtistViewModel: searchArtistViewModel)
        .environmentObject(spotify)
}



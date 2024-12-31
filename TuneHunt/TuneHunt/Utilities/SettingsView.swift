import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var menuViewModel: MenuViewModel
    @AppStorage("topTracks") private var topTracks: Int = 10
    @AppStorage("country") private var country: String = "BE"
    
    var body: some View {
        VStack {
            Form {
                selectCountry
                selectNumberOfTopTracks
            }
            .onChange(of: country) { oldValue, newValue in
                country = newValue
            }
            .onChange(of: topTracks) { oldValue, newValue in
                topTracks = newValue
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Settings")
        .background(LinearGradient(colors: [Theme(colorScheme).primaryColor, Theme(colorScheme).secondaryColor], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea())
    }
    
    var selectCountry: some View {
        Section {
            Picker("Select your country", selection: $country) {
                ForEach(menuViewModel.countries) { country in
                    Text("\(country.flag) \(country.name)").tag(country.alpha_2)
                }
            }
        } header: {
            Text("Top tracks market")
        }
    }
    
    var selectNumberOfTopTracks: some View {
        Section {
            Picker("Number of top tracks", selection: $topTracks) {
                ForEach(1...10, id: \.self) { value in
                    Text("\(value)").tag(value)
                }
            }
        } header: {
            Text("Top tracks number")
        }
    }
}

#Preview {
    SettingsView(menuViewModel: MenuViewModel())
}

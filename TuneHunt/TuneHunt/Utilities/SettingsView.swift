// TODO: number of top tracks
// TODO: country : BE, ...
// Use userdefaults: https://www.hackingwithswift.com/books/ios-swiftui/storing-user-settings-with-userdefaults

import SwiftUI

struct SettingsView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @AppStorage("topTracks") private var topTracks: Int = 10
    @AppStorage("country") private var country: String = "BE"
    
    private var countries: [Country] = Bundle.main.decode("countries.json")
    
    var body: some View {
//        NavigationStack {
            VStack {
                Form {
                    Section {
                        Picker("Select your country", selection: $country) {
                            ForEach(countries) { country in
                                Text("\(country.flag) \(country.name)").tag(country.alpha_2)
                            }
                        }
                    } header: {
                        Text("Top tracks market")
                    }
                    
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
//        }
    }
}

#Preview {
    SettingsView()
}

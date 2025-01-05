import SwiftUI

struct DefaultNoResults: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Text("No results")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .foregroundColor(Theme(colorScheme).textColor)
            .font(.title)
            .opacity(0.6)
    }
}

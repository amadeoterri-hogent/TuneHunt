import SwiftUI

struct DefaultProgressView: View {
    var progressViewText = ""
    
    var body: some View {
        ProgressView(progressViewText)
            .progressViewStyle(.circular)
            .padding(36)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 15)
    }
}

import SwiftUI

struct DefaultCaption: View {
    var captionText = ""
    
    var body: some View {
        Text(captionText)
            .font(.caption2)
            .opacity(0.4)
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

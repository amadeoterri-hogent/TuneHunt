import SwiftUI

struct NavigationTitleView: View {
    var titleText = ""
    
    var body: some View {
        Text(titleText)
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

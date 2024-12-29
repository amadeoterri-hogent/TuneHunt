import SwiftUI

struct DefaultNavigationTitleView: View {
    var titleText = ""
    
    var body: some View {
        Text(titleText)
            .font(.largeTitle)
            .bold()
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuGridItemCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var shouldNavigate: Bool
    @Binding var selection: Int
    
    var menuItem: MenuItem
    
    var body: some View {
        VStack {
            Button {
                selection = menuItem.selection
                shouldNavigate = true
            } label: {
                VStack {
                    Image(systemName: menuItem.imageSystemName )
                        .resizable()
                        .scaledToFill()
                        .frame(width: 48, height: 48)
                        .padding(.horizontal, 12)
                        .padding(.bottom, 4)
                        .foregroundStyle(Theme(colorScheme).textColor)

                    Text(menuItem.listItemTitle)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                        .padding(4)
                        .lineLimit(3)
                        .foregroundStyle(Theme(colorScheme).textColor)
                }
            }
        }
        .frame(width: 144, height: 192)
        .padding()
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme(colorScheme).textColor)
        )
    }
}

#Preview {
    let menuItem: MenuItem = MenuItem(selection: 1,
             imageSystemName: "person",
             listItemTitle: "Top tracks from single artist")
    
    MenuGridItemCell(shouldNavigate: .constant(false), selection: .constant(1), menuItem:menuItem)
}

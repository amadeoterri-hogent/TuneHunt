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
                        .padding()

                    HStack {
                        Text(menuItem.listItemTitle)
                            .font(.title2)
                    }
                }
            }
        }
        .padding()
        .clipShape(.rect(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Theme(colorScheme).textColor)
        )
    }
}

#Preview {
    var menuItem: MenuItem = MenuItem(selection: 1,
             imageSystemName: "person",
             listItemTitle: "Top tracks from single artist")
    
    MenuGridItemCell(shouldNavigate: .constant(false), selection: .constant(1), menuItem:menuItem)
}
import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuListItemCell: View {
    @Binding var shouldNavigate: Bool
    @Binding var selection: Int
    
    var menuItem: MenuItem
    
    var body: some View {
        Button {
            selection = menuItem.selection
            shouldNavigate = true
        } label: {
            HStack {
                Image(systemName: menuItem.imageSystemName )
                    .font(.title2)
                    .frame(width: 48,height: 48)
                
                Text(menuItem.listItemTitle)
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
            }
            .padding(12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    var menuItem: MenuItem = MenuItem(selection: 1,
             imageSystemName: "person",
             listItemTitle: "Top tracks from single artist")
    
    MenuListItemCell(shouldNavigate: .constant(false), selection: .constant(1), menuItem:menuItem)
}

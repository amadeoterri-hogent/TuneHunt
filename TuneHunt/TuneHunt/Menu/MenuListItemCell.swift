import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuListItemCell: View {
    @Environment(\.colorScheme) var colorScheme

    @Binding var shouldNavigate: Bool
    @Binding var selection: Int
    
    var menuItem: MenuItem
    
    var body: some View {
        btnMenuListItem
    }
    
    var btnMenuListItem: some View {
        Button {
            selection = menuItem.selection
            shouldNavigate = true
        } label: {
            lblMenuListItem
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var lblMenuListItem: some View {
        HStack {
            imgLabelListItem
            txtLabelListItem
        }
        .foregroundStyle(Theme(colorScheme).textColor)
        .padding(.vertical)
    }
    
    var imgLabelListItem: some View {
        Image(systemName: menuItem.imageSystemName )
            .font(.title2)
            .frame(width: 48,height: 48)
    }
    
    var txtLabelListItem: some View {
        Text(menuItem.listItemTitle)
            .multilineTextAlignment(.leading)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
    }
}

#Preview {
    let menuItem = MenuItem(selection: 1,
             imageSystemName: "person",
             listItemTitle: "Top tracks from single artist")
    
    MenuListItemCell(shouldNavigate: .constant(false), selection: .constant(1), menuItem:menuItem)
}

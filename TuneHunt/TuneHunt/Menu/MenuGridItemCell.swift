import SwiftUI
import Combine
import SpotifyWebAPI

struct MenuGridItemCell: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var shouldNavigate: Bool
    @Binding var selection: Int
    
    var menuItem: MenuItem
    
    var body: some View {
        btnMenuGridItem
    }
    
    var btnMenuGridItem: some View {
        Button {
            selection = menuItem.selection
            shouldNavigate = true
        } label: {
            lblMenuGridItem
        }
        .frame(width: 144, height: 192)
        .padding()
        .clipShape(.rect(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme(colorScheme).textColor)
        )
    }
    
    var lblMenuGridItem: some View {
        VStack {
            imgMenuGridItem
            txtMenuGridItem
        }
        .foregroundStyle(Theme(colorScheme).textColor)
    }
    
    var imgMenuGridItem: some View {
        Image(systemName: menuItem.imageSystemName )
            .resizable()
            .scaledToFill()
            .frame(width: 48, height: 48)
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
    }
    
    var txtMenuGridItem: some View {
        Text(menuItem.listItemTitle)
            .font(.subheadline)
            .multilineTextAlignment(.center)
            .padding(4)
            .lineLimit(3)
    }
}

#Preview {
    let menuItem = MenuItem(selection: 1,
             imageSystemName: "person",
             listItemTitle: "Top tracks from single artist")
    
    MenuGridItemCell(shouldNavigate: .constant(false), selection: .constant(1), menuItem:menuItem)
}

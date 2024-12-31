import Foundation

struct MenuModel {
    
    var menuItems: [MenuItem] = [
        MenuItem(selection: 1,
                 imageSystemName: "person",
                 listItemTitle: "From top tracks by one artist"),
        MenuItem(selection: 2,
                 imageSystemName: "person.3",
                 listItemTitle: "From top tracks by multiple artists"),
        MenuItem(selection: 3,
                 imageSystemName: "photo",
                 listItemTitle: "By finding artists from image"),
        MenuItem(selection: 4,
                 imageSystemName: "music.note.list",
                 listItemTitle: "By finding artists from another playlist")
    ]
    
    var countries: [Country] = Bundle.main.decode("countries.json")
    
}

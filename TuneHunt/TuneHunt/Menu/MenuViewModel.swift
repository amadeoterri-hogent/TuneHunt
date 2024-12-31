import Foundation

class MenuViewModel: ObservableObject {
    @Published private var model = MenuModel()
    @Published var alertItem: AlertItem? = nil
    @Published var shouldNavigate = false
    @Published var selection: Int = 0
    @Published var menuStyle: MenuStyle = .list

        
    var menuItems: [MenuItem] {
        self.model.menuItems
    }
}

import SwiftUI


enum MenuStyle: String, CaseIterable, Identifiable {
    case list
    case grid

    var id: Self { self }

    var label: String {
        switch self {
        case .list:
            return "List"
        case .grid:
            return "Grid"
        }
    }

    var systemImage: String {
        switch self {
        case .list:
            return "text.justify"
        case .grid:
            return "square.grid.3x3"
        }
    }
}

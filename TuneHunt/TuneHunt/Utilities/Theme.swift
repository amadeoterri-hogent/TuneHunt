import SwiftUI

struct Theme {
    var colorScheme: ColorScheme
    
    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
    }
    
    var bgColor: Color {
        colorScheme == .dark ? .black : .white
    }
    
    var primaryColor: Color {
        colorScheme == .dark ? .darkPrimaryColor : .lightPrimaryColor
    }
    
    var secondaryColor: Color {
        colorScheme == .dark ? .darkSecondaryColor : .lightSecondaryColor
    }
}

// Custom colors
extension ShapeStyle where Self == Color {
    static var darkPrimaryColor: Color {
        Color(red: 0, green: 47/255, blue: 123/255)
    }
    
    static var lightPrimaryColor: Color {
        Color(red: 0, green: 162/255, blue: 1)
    }
    
    static var darkSecondaryColor: Color {
        Color(red: 0, green: 0, blue: 36/255)
    }
    
    static var lightSecondaryColor: Color {
        Color(red: 230/255, green: 1, blue: 1)
    }
}

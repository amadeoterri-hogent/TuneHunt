import SwiftUI

struct Theme {
    var colorScheme: ColorScheme
    
    init(_ colorScheme: ColorScheme) {
        self.colorScheme = colorScheme
    }
    
    var textColor: Color {
        colorScheme == .dark ? .white : .black
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

struct ThemeView:View {
    @State private var primarybgColor = Color.blue
    @State private var secondarybgColor = Color.white

    
    var body: some View {
        
        ScrollView {
            ColorPicker("Set the primary color", selection: $primarybgColor)
            ColorPicker("Set the secondary color", selection: $secondarybgColor)

        }
        .frame(maxWidth: .infinity)
        .background(LinearGradient(colors: [primarybgColor, secondarybgColor], startPoint: .top, endPoint: .bottom))

    }
}
#Preview {
    ThemeView()
}

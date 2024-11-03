import SwiftUI

struct AlertItem {
    
    let title: Text
    let message: Text
    
    init(title: String, message: String) {
        self.title = Text(title)
        self.message = Text(message)
    }
    
    init(title: Text, message: Text) {
        self.title = title
        self.message = message
    }

}

struct MenuItem: Hashable {
    var selection: Int
    var imageSystemName: String
    var listItemTitle: String
    
    init(selection: Int, imageSystemName: String, listItemTitle: String) {
        self.selection = selection
        self.imageSystemName = imageSystemName
        self.listItemTitle = listItemTitle
    }
}

import SwiftUI

struct BookFeedView: View {
    public var items: [BookFeedViewModel]
    
    init(items: [BookFeedViewModel]) {
        self.items = items
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        ScrollView {
            if (items.isEmpty == true) {
                ProgressView()
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(items, id: \.id) { book in
                        BookRow(book: book)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
//struct MovieFeedView_Previews: PreviewProvider {
//
//}

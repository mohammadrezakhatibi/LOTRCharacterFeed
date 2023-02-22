import SwiftUI

struct BookFeedView: View {
    public var items: [BookViewModel]
    
    init(items: [BookViewModel]) {
        self.items = items
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
    ]
    private let columnsOne = [
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
struct BookFeedView_Previews: PreviewProvider {
    static var previews: some View {
        let mockCharacters = [
            BookViewModel(id: UUID().uuidString, name: "The Two Towers", publisher: "William Morrow", ISBN13: "978-435455515RL", coverURL: URL(string: "https://lokomond.com/lotr/books/images/812hLGWChLL.jpg")!),
        ]
        Group {
            BookFeedView(items: mockCharacters)
            .previewLayout(.fixed(width: 400, height: 300))
            .previewDisplayName("Character Feed With Items - Two column")
            
            BookFeedView(items: mockCharacters)
            .previewLayout(.fixed(width: 400, height: 600))
            .previewDisplayName("Character Feed With Items - One column")
            .environment(\.sizeCategory, .accessibilityExtraLarge)
            
            BookFeedView(items: [])
            .previewLayout(.fixed(width: 400, height: 300))
            .previewDisplayName("Character Feed - No item")
        }
    }
}

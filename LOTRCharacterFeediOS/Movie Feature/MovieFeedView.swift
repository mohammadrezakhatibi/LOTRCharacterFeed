import SwiftUI

struct MovieFeedView: View {
    public var items: [MovieFeedViewModel]
    
    init(items: [MovieFeedViewModel]) {
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
                    ForEach(items, id: \.id) { movie in
                        MovieRow(movie: movie)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
struct MovieFeedView_Previews: PreviewProvider {
    static var previews: some View {
        let mockCharacters = [
            MovieFeedViewModel(id: UUID().uuidString, name: "Aragorn II Elessar", revenue: "996 Millions", rate: "75", time: "161 Minues", imageURL: URL(string: "https://lokomond.com/lotr/movies/images/A1QbAD2iMVL.jpg")!),
        ]
        Group {
            MovieFeedView(items: mockCharacters)
            .previewLayout(.fixed(width: 400, height: 300))
            .previewDisplayName("Character Feed With Items - Two column")
            
            MovieFeedView(items: mockCharacters)
            .previewLayout(.fixed(width: 400, height: 600))
            .previewDisplayName("Character Feed With Items - One column")
            .environment(\.sizeCategory, .accessibilityExtraLarge)
            
            MovieFeedView(items: [])
            .previewLayout(.fixed(width: 400, height: 300))
            .previewDisplayName("Character Feed - No item")
        }
    }
}

import SwiftUI

struct MovieFeedView: View {
    public var items: [MovieFeedViewModel]
    
    init(items: [MovieFeedViewModel]) {
        self.items = items
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
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
                    ForEach(items, id: \.id) { character in
                        MovieRow(movie: character)
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

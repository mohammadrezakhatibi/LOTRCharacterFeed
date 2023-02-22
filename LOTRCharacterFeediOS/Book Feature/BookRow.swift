import SwiftUI
import LOTRCharacterFeed

struct BookRow: View {
    private(set) var book: BookViewModel
    
    var body: some View {
        return HStack(alignment: .top) {
            ZStack(alignment: .top) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            LOTRAsyncImage(url: book.coverURL)
                            .id(3)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.30))
            }
            .frame(width: 160,height: 260)
            VStack(alignment: .leading, spacing: 12) {
                Text(book.name)
                    .id(1)
                    .font(.title2)
                    .bold()
                    .fontDesign(.serif)
                    .foregroundColor(Color.primary)
                    .padding(.bottom, 4)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "text.book.closed.fill")
                        .font(.caption)
                        .foregroundColor(Color.accentColor)
                    Text(book.publisher)
                        .foregroundColor(Color.accentColor)
                        .font(.caption)
                        .id(2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "barcode")
                        .font(.caption)
                        .foregroundColor(Color.accentColor)
                    Text(book.ISBN13)
                        .foregroundColor(Color.accentColor)
                        .font(.caption)
                        .id(2)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}


struct BookRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookRow(book: BookViewModel(id: UUID().uuidString, name: "The Two Towers", publisher: "William Morrow", ISBN13: "978-435455515RL", coverURL: URL(string: "https://lokomond.com/lotr/books/images/812hLGWChLL.jpg")!))
                .previewLayout(.sizeThatFits)
            BookRow(book: BookViewModel(id: UUID().uuidString, name: "The Two Towers", publisher: "William Morrow", ISBN13: "978-435455515RL", coverURL: URL(string: "https://lokomond.com/lotr/books/images/812hLGWChLL.jpg")!))
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
        }
    }
}


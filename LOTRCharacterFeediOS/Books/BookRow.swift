import SwiftUI
import LOTRCharacterFeed

struct BookRow: View {
    private(set) var book: BookFeedViewModel
    
    var body: some View {
        return HStack(alignment: .top) {
            ZStack(alignment: .top) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            LOTRAsyncImage(url: book.imageURL)
                            .id(5)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.30))
            }
            .frame(width: 155, height: 240)
            VStack(alignment: .leading, spacing: 12) {
                Text(book.name)
                    .id(1)
                    .font(.title2)
                    .bold()
                    .fontDesign(.serif)
                    .foregroundColor(Color.primary)
                    .padding(.bottom, 4)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "staroflife.fill")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.35))
                    Text(book.publisher)
                        .foregroundColor(Color.gray.opacity(0.85))
                        .font(.subheadline)
                        .id(2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "creditcard.fill")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.35))
                    Text(book.barcode)
                        .foregroundColor(Color.gray.opacity(0.85))
                        .font(.subheadline)
                        .id(3)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            Spacer()
        }
        .padding(.top, 8)
    }
}


struct BookRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BookRow(book: BookFeedViewModel(id: UUID().uuidString, name: "The Fellowship Of The Ring", publisher: "William Morrow", barcode: "978-0618260515", imageURL: URL(string: "https://lokomond.com/lotr/movies/images/A1QbAD2iMVL.jpg")!))
                .previewLayout(.sizeThatFits)
        }
    }
}

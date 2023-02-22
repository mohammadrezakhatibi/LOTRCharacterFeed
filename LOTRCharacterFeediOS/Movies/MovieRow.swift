import SwiftUI
import LOTRCharacterFeed

struct MovieRow: View {
    private(set) var movie: MovieFeedViewModel
    
    var body: some View {
        return HStack(alignment: .top) {
            ZStack(alignment: .top) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            LOTRAsyncImage(url: movie.posterURL)
                            .id(5)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.30))
            }
            .frame(width: 155, height: 240)
            VStack(alignment: .leading, spacing: 12) {
                Text(movie.name)
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
                    Text(movie.score)
                        .foregroundColor(Color.gray.opacity(0.85))
                        .font(.subheadline)
                        .id(2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "creditcard.fill")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.35))
                    Text(movie.revenue)
                        .foregroundColor(Color.gray.opacity(0.85))
                        .font(.subheadline)
                        .id(2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.subheadline)
                        .foregroundColor(Color.gray.opacity(0.35))
                    Text(movie.runtime)
                        .foregroundColor(Color.gray.opacity(0.85))
                        .font(.subheadline)
                        .id(2)
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            Spacer()
        }
        .padding(.top, 8)
    }
}


struct MovieRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MovieRow(movie: MovieFeedViewModel(id: UUID().uuidString, name: "The Battle of the Five Armies", revenue: "956", score: "75", runtime: "161", posterURL: URL(string: "https://lokomond.com/lotr/movies/images/A1QbAD2iMVL.jpg")!))
                .previewLayout(.sizeThatFits)
        }
    }
}

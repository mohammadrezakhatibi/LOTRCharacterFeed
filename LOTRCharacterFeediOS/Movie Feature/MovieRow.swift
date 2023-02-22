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
                            LOTRAsyncImage(url: movie.imageURL)
                            .id(3)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.30))
            }
            .frame(width: 160,height: 260)
            VStack(alignment: .leading, spacing: 12) {
                Text(movie.name)
                    .id(1)
                    .font(.title2)
                    .bold()
                    .fontDesign(.serif)
                    .foregroundColor(Color.primary)
                    .padding(.bottom, 4)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.caption)
                        .foregroundColor(Color.accentColor)
                    Text(movie.revenue)
                        .foregroundColor(Color.accentColor)
                        .font(.caption)
                        .id(2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "staroflife.fill")
                        .font(.caption)
                        .foregroundColor(Color.accentColor)
                    Text(movie.rate)
                        .foregroundColor(Color.accentColor)
                        .font(.caption)
                        .id(2)
                }
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(Color.accentColor)
                    Text(movie.time)
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
    }
}


struct MovieRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MovieRow(movie: MovieFeedViewModel(id: UUID().uuidString, name: "The Battle of the Five Armies", revenue: "956", rate: "75", time: "161", imageURL: URL(string: "https://lokomond.com/lotr/movies/images/A1QbAD2iMVL.jpg")!))
                .previewLayout(.sizeThatFits)
        }
    }
}


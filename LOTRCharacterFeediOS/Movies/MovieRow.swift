import SwiftUI
import LOTRCharacterFeed

struct MovieRow: View {
    private(set) var movie: MovieFeedViewModel
    
    var body: some View {
        return VStack {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            LOTRAsyncImage(url: movie.posterURL)
                            .id(3)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.70))
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.75), .white.opacity(0)]), startPoint: .bottom, endPoint: .top)
                    .cornerRadius(8)
                    .clipped()
                    .id(4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(movie.name)
                        .id(1)
                        .font(.title2)
                        .fontDesign(.serif)
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Image(systemName: "folder")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(movie.score)
                            .foregroundColor(.yellow)
                            .font(.caption)
                            .id(2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(height: 260)
            .padding(.top, 8)
        }
    }
}

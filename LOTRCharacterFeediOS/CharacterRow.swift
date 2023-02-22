//
//  CharacterRow.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/2/23.
//

import SwiftUI
import LOTRCharacterFeed

struct CharacterRow: View {
    private(set) var character: CharacterFeedViewModel
    var body: some View {
        return HStack(alignment: .top) {
            ZStack(alignment: .top) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            LOTRAsyncImage(url: character.imageURL)
                            .id(3)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.30))
            }
            .frame(width: 155, height: 240)
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(character.race)
                        .foregroundColor(Color.gray.opacity(0.85))
                        .font(.caption)
                        .id(2)
                }
                Text(character.name)
                    .id(1)
                    .font(.title2)
                    .bold()
                    .fontDesign(.serif)
                    .foregroundColor(Color.primary)
                    .padding(.bottom, 4)
                Text(character.birth)
                    .foregroundColor(Color.gray.opacity(0.85))
                    .font(.subheadline)
                    .id(3)
                Text(character.realm)
                    .foregroundColor(Color.gray.opacity(0.85))
                    .font(.subheadline)
                    .id(4)
                Spacer()
            }
            .padding(.leading, 8)
            .padding(.trailing, 16)
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}


struct CharacterRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CharacterRow(character: CharacterFeedViewModel(id: UUID().uuidString, name: "Aragorn II Elessar", race: "Human", birth: "March 1 ,2931", realm: "eunited Kingdom,Arnor,Gondor", imageURL: URL(string: "https://lokomond.com/lotr/characters/images/Aragorn_II_Elessar.jpg")!))
                .previewLayout(.sizeThatFits)
        }
    }
}

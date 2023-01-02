//
//  CharacterRow.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/2/23.
//

import SwiftUI
import LOTRCharacterFeed

struct CharacterRow: View {
    private(set) var character: CharacterItem
    
    var body: some View {
        return VStack {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            AsyncImage(url: character.imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } placeholder: {
                                
                            }
                            .id(3)
                    }
                    .foregroundColor(.black)
                    .frame(minHeight: 240)
                    .cornerRadius(16)
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .white.opacity(0)]), startPoint: .bottom, endPoint: .top)
                    .cornerRadius(16)
                    .clipped()
                    .id(4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(character.name)
                        .id(1)
                        .font(.title)
                        .fontDesign(.serif)
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    HStack(alignment: .center) {
                        Image("race")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .scaledToFill()
                            .clipped()
                        Text(character.race)
                            .foregroundColor(.yellow)
                            .font(.body)
                            .id(2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .clipped()
        }
        }
    }
}

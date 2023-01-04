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
                    }
                
                    .cornerRadius(16)
                    .clipped()
                    .foregroundColor(.gray.opacity(0.85))
                    .frame(minHeight: 240)
                
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
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Image(systemName: "folder")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                        Text(character.race)
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                            .id(2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(height: 240)
        }
    }
}

//
//  CachedImage.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/6/23.
//

import SwiftUI
import LOTRCharacterFeed

public struct LOTRAsyncImage: View {
    private let url: URL
    private let cacheLoader: ImageLoader
    @State var data: Data?
    
    init(url: URL, cacheLoader: ImageLoader) {
        self.url = url
        self.cacheLoader = cacheLoader
    }
    
    @ViewBuilder
    public var body: some View {
        if let data = data {
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .scaledToFill()
                .frame(height: 260, alignment: .top)
                .clipped()
        } else {
            VStack {
                
            }
            .task {
                data = await loadImage()
            }
        }
    }
    
    public func loadImage() async -> Data? {
        return await withCheckedContinuation { continuation in
            cacheLoader.loadImageData(url: url) { result in
                continuation.resume(with: .success(try? result.get()))
            }
        }
    }
}

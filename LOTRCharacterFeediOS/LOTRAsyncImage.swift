//
//  CachedImage.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/6/23.
//

import SwiftUI
import LOTRCharacterFeed

public struct LOTRAsyncImage: View {
    public let url: URL
    
    private let cacheLoader: ImageCacheLoader = {
        let client = URLSessionHTTPClient()
        let loader = RemoteCharacterImageDataLoader(client: client)
        let store = NSCache<NSURL, NSData>()
        store.totalCostLimit = 1024 * 1024 * 100
        store.countLimit = 100
        return ImageCacheLoader(loader: loader, cache: store, imageFileCache: ImageFileCache())
    }()
    
    @State var data: Data?
    
    @ViewBuilder
    public var body: some View {
        if let data = data {
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
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

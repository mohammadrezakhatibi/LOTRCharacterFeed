//
//  LOTRAppApp.swift
//  LOTRApp
//
//  Created by mohammadreza on 1/4/23.
//

import SwiftUI
import LOTRCharacterFeediOS
import LOTRCharacterFeed

@main
struct LOTRAppApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                CharacterFeedView()
                    .navigationTitle("Characters")
            }
        }
    }
    
    private func CharacterFeedView() -> some View {
        let cacheURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let diskCacheURL = cacheURL.appendingPathComponent("DownloadCache")
        let cache = URLCache(memoryCapacity: 10_000_000, diskCapacity: 1_000_000_000, directory: diskCacheURL)
        print(diskCacheURL)
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        let session = URLSession(configuration: config)
        let client = URLSessionHTTPClient(session: session)
        let request = CharacterRequest().create()
        let loader = RemoteCharacterLoader(request: request, client: client)
        let vm = CharacterFeedDataProvider(loader: MainQueueDispatchDecorator(decoratee: loader))
        let view = CharacterFeed(viewModel: vm, imageLoader: cacheLoader)
        return view
    }
    
    private let cacheLoader: CharacterImageDataLoader = {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteCharacterImageDataLoader(client: client)
        let store = NSCache<NSURL, NSData>()
        store.totalCostLimit = 1024 * 1024 * 100
        store.countLimit = 100
        return ImageLoaderWithCache(loader: loader, cache: store, imageFileCache: ImageFileCache())
    }()
    
    private struct CharacterRequest: RemoteRequest {
        var url: URL = URL(string: "https://lokomond.com/lotr/lotr_characters.json")!
        var header: [String : String]? = ["Authorization" : "Bearer 4FVcNlyhfHkLwFuqo-YP"]
        
        func create() -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.allHTTPHeaderFields = header
            return request
        }
    }
}

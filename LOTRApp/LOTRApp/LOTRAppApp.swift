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
        let client = URLSessionHTTPClient()
        let request = CharacterRequest().create()
        let loader = RemoteCharacterLoader(request: request, client: client)
        let vm = CharacterFeedDataProvider(loader: loader)
        let view = CharacterFeed(viewModel: vm)
        return view
    }
    
    private struct CharacterRequest: RemoteRequest {
        var url: URL = URL(string: "https://the-one-api.dev/v2/character")!
        var header: [String : String]? = ["Authorization" : "Bearer 4FVcNlyhfHkLwFuqo-YP"]
        
        func create() -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.allHTTPHeaderFields = header
            return request
        }
    }
}

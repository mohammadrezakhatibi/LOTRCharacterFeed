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
        let session = URLSession(configuration: .default)
        let client = URLSessionHTTPClient(session: session)
        let request = CharacterRequest().create()
        let loader = RemoteCharacterLoader(request: request, client: client)
        let vm = CharacterFeedDataProvider(loader: MainQueueDispatchDecorator(decoratee: loader))
        let view = CharacterFeedViewContainer(viewModel: vm)
        return view
    }
    
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

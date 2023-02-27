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
            TabView {
                NavigationStack {
                    CharacterFeedView()
                        .navigationTitle("Characters")
                }.tabItem {
                    Label("Characters", systemImage: "person.2.fill")
                }
                NavigationStack {
                    MoviesFeedView()
                        .navigationTitle("Movies")
                }.tabItem {
                    Label("Movies", systemImage: "film.stack.fill")
                }
                NavigationStack {
                    BooksFeedView()
                        .navigationTitle("Books")
                }.tabItem {
                    Label("Books", systemImage: "books.vertical.fill")
                }
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
    
    private func MoviesFeedView() -> some View {
        let session = URLSession(configuration: .default)
        let client = URLSessionHTTPClient(session: session)
        let request = MoviesRequest().create()
        let loader = RemoteMovieLoader(request: request, client: client)
        let vm = MoviesFeedDataProvider(loader: MainQueueDispatchDecorator(decoratee: loader))
        let view = MoviesFeedViewContainer(viewModel: vm)
        return view
    }
    
    private func BooksFeedView() -> some View {
        let session = URLSession(configuration: .default)
        let client = URLSessionHTTPClient(session: session)
        let request = BooksRequest().create()
        let loader = RemoteBooksLoader(request: request, client: client)
        let vm = BooksFeedDataProvider(loader: MainQueueDispatchDecorator(decoratee: loader))
        let view = BooksFeedViewContainer(viewModel: vm)
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
    
    private struct MoviesRequest: RemoteRequest {
        var url: URL = URL(string: "https://lokomond.com/lotr/movies.json")!
        
        func create() -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.allHTTPHeaderFields = header
            return request
        }
    }
    
    private struct BooksRequest: RemoteRequest {
        var url: URL = URL(string: "https://lokomond.com/lotr/books.json")!
        
        func create() -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.allHTTPHeaderFields = header
            return request
        }
    }
}

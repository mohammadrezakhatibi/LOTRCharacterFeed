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
                }
                .tabItem {
                    Label("Characters", systemImage: "person.2.fill")
                }
                
                NavigationStack {
                    MovieFeedView()
                        .navigationTitle("Movies")
                }
                .tabItem {
                    Label("Movies", systemImage: "film.stack.fill")
                }
                
                NavigationStack {
                    BooksFeedView()
                        .navigationTitle("Books")
                }
                .tabItem {
                    Label("Books", systemImage: "books.vertical.fill")
                }
            }
        }
    }
    
    private func CharacterFeedView() -> some View {
        let session = URLSession(configuration: .default)
        let client = URLSessionHTTPClient(session: session)
        let request = CharacterRequest().create()
        let loader = RemoteLoader(request: request, client: client, mapper: CharacterItemMapper.map)
        let vm = CharacterFeedDataProvider(loader: loader)
        let view = CharacterFeedViewContainer(viewModel: vm)
        return view
    }
    
    private func MovieFeedView() -> some View {
        let session = URLSession(configuration: .default)
        let client = URLSessionHTTPClient(session: session)
        let request = MovieRequest().create()
        let loader = RemoteLoader(request: request, client: client, mapper: MovieItemMapper.map)
        let vm = MoviesDataProvider(loader: loader)
        let view = MovieViewContainer(viewModel: vm)
        return view
    }
    
    private func BooksFeedView() -> some View {
        let session = URLSession(configuration: .default)
        let client = URLSessionHTTPClient(session: session)
        let request = BooksRequest().create()
        let loader = RemoteLoader(request: request, client: client, mapper: BookItemMapper.map)
        let vm = BooksDataProvider(loader: loader)
        let view = BookViewContainer(viewModel: vm)
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
    
    private struct MovieRequest: RemoteRequest {
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

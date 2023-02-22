import Foundation
import XCTest
import SwiftUI
import ViewInspector
import LOTRCharacterFeed
@testable import LOTRCharacterFeediOS

final class MovieFeedUIAcceptanceTests: XCTestCase {
    
    func test_init_createsAList() throws {
        let sut = makeSUT()
        XCTAssertNoThrow(try sut.inspect().find(MovieFeedView.self).scrollView())
    }

    func test_loadMovies_deliversAListOfMovies() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { view in
            let cells = try view.find(MovieFeedView.self).findAll(MovieRow.self)
    
            XCTAssertEqual(cells.count, items.count)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMovies_displaysMovieListOnSuccessfulLoadMovies() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            try self.render(view, for: items)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMovie_doesNotShowErrorOnSuccessfulLoadMovies() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            self.hideErrorAlert(in: view)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMovies_showsErrorOnFailureLoadMovies() throws {
        let anyError = NSError(domain: "an error", code: 0)
        var sut = makeSUT(result: .failure(anyError))
        
        let exp = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            self.renderErrorAlert(in: view, with: anyError)
            try view.find(MovieFeedView.self).alert().actions().first?.button().tap()
            self.hideErrorAlert(in: view)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMovies_displaysLoadingIndicatorOnLoading() {
        let loader = MoviesLoaderSpy()
        let vm = MoviesFeedDataProvider(loader: loader)
        let sut = MoviesFeedViewContainer(viewModel: vm)
        
        XCTAssertNoThrow(try sut.inspect().find(MovieFeedView.self).scrollView().progressView())
        
        let exp = expectation(description: "Wait for load completion")
        loader.load { _ in
            XCTAssertNoThrow(try? sut.inspect().scrollView().lazyVGrid())
            exp.fulfill()
        }
        
        loader.complete(with: makeItems(), at: 0)
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(result: RemoteMovieLoader.Result = .success([]), file: StaticString = #filePath, line: UInt = #line) -> MoviesFeedViewContainer {
        
        let loader = MoviesLoaderStub(result: result)
        let vm = MoviesFeedDataProvider(loader: loader)
        let sut = MoviesFeedViewContainer(viewModel: vm)
        
        trackingForMemoryLeaks(loader, file: file, line: line)
        trackingForMemoryLeaks(vm, file: file, line: line)
        
        return sut
    }
    
    private func render(_ view: InspectableView<ViewType.View<MoviesFeedViewContainer>>, for items: [MovieItem]) throws {
        let row = try view.find(MovieFeedView.self).scrollView().lazyVGrid().findAll(MovieRow.self)
        try? items.enumerated().forEach { index, item in
            guard row.count == items.count else {
                XCTFail("Couldn't find any rows")
                return
            }
            XCTAssertEqual(try row[index].find(viewWithId: 1).text().string(), item.name)
            XCTAssertEqual(try row[index].find(viewWithId: 2).text().string(), "\(item.score)")
            XCTAssertNotNil(try row[index].find(LOTRAsyncImage.self).actualView())
            XCTAssertEqual(try row[index].find(LOTRAsyncImage.self).actualView().url.absoluteString, item.posterURL.absoluteString)
            XCTAssertNotNil(try row[index].find(viewWithId: 4).linearGradient())
            
        }
    }
    
    private func hideErrorAlert(in view: InspectableView<ViewType.View<MoviesFeedViewContainer>>) {
        XCTAssertEqual(try view.actualView().viewModel.isErrorPresented, false)
        XCTAssertEqual(try view.actualView().viewModel.errorMessage, "")
        XCTAssertThrowsError(try view.scrollView().alert())
        XCTAssertThrowsError(try view.scrollView().alert().title().string())
        XCTAssertThrowsError(try view.scrollView().alert().message().text().string())
    }
    
    private func renderErrorAlert(in view: InspectableView<ViewType.View<MoviesFeedViewContainer>>, with error: Error) {
        XCTAssertEqual(try view.actualView().viewModel.isErrorPresented, true)
        XCTAssertEqual(try view.actualView().viewModel.errorMessage, error.localizedDescription)
        XCTAssertNotNil(try view.find(MovieFeedView.self).alert())
        XCTAssertEqual((try view.find(MovieFeedView.self).alert().title().string()), "Error")
        XCTAssertEqual((try view.find(MovieFeedView.self).alert().message().text().string()), error.localizedDescription)
    }
    
    private func makeItems() -> [MovieItem] {
        return [
            MovieItem(
                id: "id1",
                name: "name",
                runtime: 1.0,
                budget: 1.0,
                revenue: 1.0,
                academyAwardNominations: 1,
                academyAwardWins: 1,
                score: 1.0,
                posterURL: URL(string: "https://any-url.com")!
            ),
            MovieItem(
                id: "id2",
                name: "another name",
                runtime: 2.0,
                budget: 2.0,
                revenue: 2.0,
                academyAwardNominations: 2,
                academyAwardWins: 2,
                score: 2.0,
                posterURL: URL(string: "https://any-url.com")!
            ),
        ]
    }
    
    private final class MoviesLoaderStub: MovieLoader {
                
        private let result: RemoteMovieLoader.Result
        
        init(result: RemoteMovieLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (RemoteMovieLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private final class MoviesLoaderSpy: MovieLoader {
                
        private var results = [(RemoteMovieLoader.Result) -> Void]()
        
        func load(completion: @escaping (RemoteMovieLoader.Result) -> Void) {
            results.append(completion)
        }
        
        func complete(with items: [MovieItem], at index: Int) {
            results[index](.success(items))
        }
    }
}

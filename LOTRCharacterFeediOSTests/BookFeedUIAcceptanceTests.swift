import Foundation
import XCTest
import SwiftUI
import ViewInspector
import LOTRCharacterFeed
@testable import LOTRCharacterFeediOS

final class BookFeedUIAcceptanceTests: XCTestCase {
    
    func test_init_createsAList() throws {
        let sut = makeSUT()
        XCTAssertNoThrow(try sut.inspect().find(BookFeedView.self).scrollView())
    }

    func test_loadBooks_deliversAListOfBooks() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { view in
            let cells = try view.find(BookFeedView.self).findAll(BookRow.self)
    
            XCTAssertEqual(cells.count, items.count)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadBooks_displaysMovieListOnSuccessfulLoadBooks() throws {
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
            try view.find(BookFeedView.self).alert().actions().first?.button().tap()
            self.hideErrorAlert(in: view)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadMovies_displaysLoadingIndicatorOnLoading() {
        let loader = BooksLoaderSpy()
        let vm = BooksFeedDataProvider(loader: loader)
        let sut = BooksFeedViewContainer(viewModel: vm)
        
        XCTAssertNoThrow(try sut.inspect().find(BookFeedView.self).scrollView().progressView())
        
        let exp = expectation(description: "Wait for load completion")
        loader.load { _ in
            XCTAssertNoThrow(try? sut.inspect().scrollView().lazyVGrid())
            exp.fulfill()
        }
        
        loader.complete(with: makeItems(), at: 0)
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(result: RemoteBooksLoader.Result = .success([]), file: StaticString = #filePath, line: UInt = #line) -> BooksFeedViewContainer {
        
        let loader = BooksLoaderStub(result: result)
        let vm = BooksFeedDataProvider(loader: loader)
        let sut = BooksFeedViewContainer(viewModel: vm)
        
        trackingForMemoryLeaks(loader, file: file, line: line)
        trackingForMemoryLeaks(vm, file: file, line: line)
        
        return sut
    }
    
    private func render(_ view: InspectableView<ViewType.View<BooksFeedViewContainer>>, for items: [BookItem]) throws {
        let row = try view.find(BookFeedView.self).scrollView().lazyVGrid().findAll(BookRow.self)
        try? items.enumerated().forEach { index, item in
            guard row.count == items.count else {
                XCTFail("Couldn't find any rows")
                return
            }
            XCTAssertEqual(try row[index].find(viewWithId: 1).text().string(), item.name)
            XCTAssertEqual(try row[index].find(viewWithId: 2).text().string(), "\(item.publisher)")
            XCTAssertNotNil(try row[index].find(LOTRAsyncImage.self).actualView())
            XCTAssertEqual(try row[index].find(LOTRAsyncImage.self).actualView().url.absoluteString, item.coverURL.absoluteString)
            
        }
    }
    
    private func hideErrorAlert(in view: InspectableView<ViewType.View<BooksFeedViewContainer>>) {
        XCTAssertEqual(try view.actualView().viewModel.isErrorPresented, false)
        XCTAssertEqual(try view.actualView().viewModel.errorMessage, "")
        XCTAssertThrowsError(try view.scrollView().alert())
        XCTAssertThrowsError(try view.scrollView().alert().title().string())
        XCTAssertThrowsError(try view.scrollView().alert().message().text().string())
    }
    
    private func renderErrorAlert(in view: InspectableView<ViewType.View<BooksFeedViewContainer>>, with error: Error) {
        XCTAssertEqual(try view.actualView().viewModel.isErrorPresented, true)
        XCTAssertEqual(try view.actualView().viewModel.errorMessage, error.localizedDescription)
        XCTAssertNotNil(try view.find(BookFeedView.self).alert())
        XCTAssertEqual((try view.find(BookFeedView.self).alert().title().string()), "Error")
        XCTAssertEqual((try view.find(BookFeedView.self).alert().message().text().string()), error.localizedDescription)
    }
    
    private func makeItems() -> [BookItem] {
        return [
            BookItem(
                id: "id1",
                name: "name",
                publisher: "publisher",
                barcode: "a barcode",
                coverURL: URL(string: "https://any-url.com")!
            ),
            BookItem(
                id: "id2",
                name: "another name",
                publisher: "another publisher",
                barcode: "another barcode",
                coverURL: URL(string: "https://any-url.com")!
            ),
        ]
    }
    
    private final class BooksLoaderStub: BooksLoader {
                
        private let result: RemoteBooksLoader.Result
        
        init(result: RemoteBooksLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (RemoteBooksLoader.Result) -> Void) {
            completion(result)
        }
    }
    
    private final class BooksLoaderSpy: BooksLoader {
                
        private var results = [(RemoteBooksLoader.Result) -> Void]()
        
        func load(completion: @escaping (RemoteBooksLoader.Result) -> Void) {
            results.append(completion)
        }
        
        func complete(with items: [BookItem], at index: Int) {
            results[index](.success(items))
        }
    }
}

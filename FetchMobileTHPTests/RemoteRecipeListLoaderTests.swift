//
//  RemoteRecipeListLoaderTests.swift
//  FetchMobileTHPTests
//

import XCTest
@testable import FetchMobileTHP

final class RemoteRecipeListLoaderTests: XCTestCase {
	func test_init_doesNotRequestDataFromURL() {
		let (_, client) = makeSUT()

		XCTAssertTrue(client.requestedURLs.isEmpty)
	}

	func test_load_requestsDataFromURL() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url])
	}

	func test_loadTwice_requestsDataFromURLTwice() {
		let url = URL(string: "https://a-given-url.com")!
		let (sut, client) = makeSUT(url: url)

		sut.load { _ in }
		sut.load { _ in }

		XCTAssertEqual(client.requestedURLs, [url, url])
	}

	func test_load_deliversErrorOnClientError() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.connectivity)) {
			let error = NSError(domain: "Test", code: 0)
			client.complete(with: error)
		}
	}

	func test_load_deliversErrorOnNon200HTTPResponse() {
		let (sut, client) = makeSUT()

		let samples = [199, 201, 300, 400, 500]
		samples.enumerated().forEach { index, code in
			expect(sut, toCompleteWith: failure(.invalidData)) {
				let jsonData = makeItemsJSON([])
				client.complete(withStatusCode: code, at: index, data: jsonData)
			}
		}
	}

	func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: failure(.invalidData)) {
			let invalidJSON = Data("invalid json".utf8)
			client.complete(withStatusCode: 200, data: invalidJSON)
		}
	}

	func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
		let (sut, client) = makeSUT()

		expect(sut, toCompleteWith: .success([])) {
			let emptyListJSON = makeItemsJSON([])
			client.complete(withStatusCode: 200, data: emptyListJSON)
		}
	}

	func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
		let (sut, client) = makeSUT()

		let item1 = makeItem(uuid: UUID().uuidString, cuisine: "American", name: "Nachos", photo_url_large: nil, photo_url_small: nil, source_url: nil, youtube_url: nil)

		let item2 = makeItem(uuid: UUID().uuidString, cuisine: "American", name: "Smashburger", photo_url_large: nil, photo_url_small: nil, source_url: nil, youtube_url: "https://a-url.com")

		let items = [item1.model, item2.model]

		expect(sut, toCompleteWith: .success(items)) {
			let jsonData = makeItemsJSON([item1.json, item2.json])
			client.complete(withStatusCode: 200, data: jsonData)
		}
	}

	func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
		let url = URL(string: "https://a-url.com")!
		let client = HTTPClientSpy()
		var sut: RemoteRecipeListLoader? = RemoteRecipeListLoader(url: url, client: client)

		var capturedResults = [RemoteRecipeListLoader.Result]()
		sut?.load { capturedResults.append($0) }

		sut = nil
		client.complete(withStatusCode: 200, data: makeItemsJSON([]))

		XCTAssertTrue(capturedResults.isEmpty)
	}

	// MARK: - Helpers

	private func makeItem(uuid: String, cuisine: String, name: String, photo_url_large: String?, photo_url_small: String?, source_url: String?, youtube_url: String?) -> (model: RecipeItem, json: [String: Any]) {
		let item = RecipeItem(cuisine: cuisine, name: name, photo_url_large: photo_url_large, photo_url_small: photo_url_small, source_url: source_url, uuid: uuid, youtube_url: youtube_url)

		let json = [
			"cuisine": cuisine,
			"name": name,
			"uuid": uuid,
			"photo_url_large": photo_url_large,
			"photo_url_small": photo_url_small,
			"source_url": source_url,
			"youtube_url": youtube_url
		].reduce(into: [String: Any]()) { (acc, e) in
			if let value = e.value {
				acc[e.key] = value
			}
		}

		return (item, json)
	}

	private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
		let itemsJSON = ["recipes": items]
		return try! JSONSerialization.data(withJSONObject: itemsJSON)
	}

	private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteRecipeListLoader, client: HTTPClientSpy) {
		let client = HTTPClientSpy()
		let sut = RemoteRecipeListLoader(url: url, client: client)
		trackForMemoryLeaks(client)
		trackForMemoryLeaks(sut)
		return (sut, client)
	}

	private func failure(_ error: RemoteRecipeListLoader.Error) -> RemoteRecipeListLoader.Result {
		return .failure(error)
	}

	private func expect(_ sut: RemoteRecipeListLoader, toCompleteWith expectedResult: RemoteRecipeListLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
		let exp = expectation(description: "wait for load completion")
		sut.load { receivedResult in
			switch (receivedResult, expectedResult) {
			case let (.success(receivedItems), .success(expectedItems)):
				XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

			case let (.failure(receivedError as RemoteRecipeListLoader.Error), .failure(exectedError as RemoteRecipeListLoader.Error)):
				XCTAssertEqual(receivedError, exectedError, file: file, line: line)

			default:
				XCTFail("Expected \(expectedResult) but received \(receivedResult) instead.", file: file, line: line)
			}

			exp.fulfill()
		}

		action()

		wait(for: [exp], timeout: 1.0)
	}

	private final class HTTPClientSpy: HTTPClient {
		private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()

		var requestedURLs: [URL] {
			return messages.map { $0.url }
		}

		func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
			messages.append((url, completion))
		}

		func get(from url: URL) async -> Result<(Data, HTTPURLResponse), any Error> {
			fatalError()
		}

		func complete(withStatusCode statusCode: Int, at index: Int = 0, data: Data) {
			let response = HTTPURLResponse(
				url: requestedURLs[index],
				statusCode: statusCode,
				httpVersion: nil,
				headerFields: nil
			)!

			messages[index].completion(.success((data, response)))
		}

		func complete(with error: Error, at index: Int = 0) {
			messages[index].completion(.failure(error))
		}
	}
}

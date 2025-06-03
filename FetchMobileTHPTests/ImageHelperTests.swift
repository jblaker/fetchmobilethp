//
//  ImageHelperTests.swift
//  FetchMobileTHPTests
//

import XCTest
@testable import FetchMobileTHP

final class ImageHelperTests: XCTestCase {
	func test_loadImage() async {
		let recipe = anyRecipe()

		let client = HTTPClientSpy()

		// Load small first
		var (data, cached) = await ImageHelper.loadImage(forRecipe: recipe, forSize: .small, withClient: client)!
		XCTAssertNotNil(data)
		XCTAssertFalse(cached)

		(data, cached) = await ImageHelper.loadImage(forRecipe: recipe, forSize: .small, withClient: client)!
		XCTAssertNotNil(data)
		XCTAssertTrue(cached)

		// Should have only made one network call for small
		XCTAssertEqual(client.getCount, 1)

		// Load large
		(data, cached) = await ImageHelper.loadImage(forRecipe: recipe, forSize: .large, withClient: client)!
		XCTAssertNotNil(data)
		XCTAssertFalse(cached)

		(data, cached) = await ImageHelper.loadImage(forRecipe: recipe, forSize: .large, withClient: client)!
		XCTAssertNotNil(data)
		XCTAssertTrue(cached)

		// Should have two networks calls now, one for small and one for large
		XCTAssertEqual(client.getCount, 2)
	}

	// MARK: - Helpers

	private func anyRecipe() -> RecipeItem {
		return RecipeItem(
			cuisine: "Malaysian",
			name: "Apam Balik",
			photo_url_large: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
			photo_url_small: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
			source_url: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
			uuid: UUID().uuidString,
			youtube_url: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
		)
	}

	private final class HTTPClientSpy: HTTPClient {
		var statusCode = 200
		var getCount = 0

		func get(from url: URL, completion: @escaping (Result<(Data, HTTPURLResponse), any Error>) -> Void) {
			// NO-OP
		}

		func get(from url: URL) async -> Result<(Data, HTTPURLResponse), any Error> {
			getCount += 1
			let response = HTTPURLResponse(
				url: url,
				statusCode: statusCode,
				httpVersion: nil,
				headerFields: nil
			)!
			return .success((Data(), response))
		}
	}
}

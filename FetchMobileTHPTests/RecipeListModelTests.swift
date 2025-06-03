//
//  RecipeListModelTests.swift
//  FetchMobileTHPTests
//

import XCTest
@testable import FetchMobileTHP

final class RecipeListModelTests: XCTestCase {
	func test_load_newLoader() async {
		let loader = RecipeListLoaderSpy()
		loader.recipes = [anyRecipe(), anyRecipe(), anyRecipe(withCuisine: "American")]

		let sut = await RecipeListModel()
		await sut.load(with: loader)

		XCTAssertEqual(loader.loadCount, 1)

		await MainActor.run {
			XCTAssertEqual(sut.recipeItems.count, 3)
			XCTAssertEqual(sut.cuisineTypes.count, 2)
		}
	}

	func test_load_existingLoader() async {
		let loader = RecipeListLoaderSpy()
		loader.recipes = [anyRecipe(), anyRecipe(withCuisine: "Nebraska"), anyRecipe(withCuisine: "American")]

		let sut = await RecipeListModel()
		await sut.load(with: loader)
		await sut.load()

		XCTAssertEqual(loader.loadCount, 2)

		await MainActor.run {
			XCTAssertEqual(sut.recipeItems.count, 3)
			XCTAssertEqual(sut.cuisineTypes.count, 3)
		}
	}

	private final class RecipeListLoaderSpy: RecipeListLoader {
		var recipes: [RecipeItem]?
		var loadCount = 0

		func load() async -> RecipeListLoader.Result {
			loadCount += 1
			guard let recipes else {
				return .failure(NSError(domain: "", code: 100))
			}

			return .success(recipes)
		}

		func load(withCompletion completion: @escaping (RecipeListLoader.Result) -> Void) {
			fatalError("This method should not be called during tests")
		}

		static func CreateLoader() -> (any FetchMobileTHP.RecipeListLoader)? {
			return RecipeListLoaderSpy()
		}
	}

	private func anyRecipe(withCuisine cuisine: String = "Malaysian") -> RecipeItem {
		return RecipeItem(
			cuisine: cuisine,
			name: "Apam Balik",
			photo_url_large: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
			photo_url_small: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
			source_url: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
			uuid: UUID().uuidString,
			youtube_url: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
		)
	}
}

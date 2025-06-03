//
//  FavoritesHelperTests.swift
//  FetchMobileTHPTests
//

import XCTest
@testable import FetchMobileTHP

final class FavoritesHelperTests: XCTestCase {
	func test_toggleFavorite() {
		let recipe = anyRecipe()
		let recipe2 = anyRecipe()

		XCTAssertFalse(FavoritesHelper.recipeIsFavorited(recipe: recipe))
		XCTAssertFalse(FavoritesHelper.recipeIsFavorited(recipe: recipe2))

		FavoritesHelper.addFavorite(recipe: recipe)

		XCTAssertTrue(FavoritesHelper.recipeIsFavorited(recipe: recipe))
		XCTAssertFalse(FavoritesHelper.recipeIsFavorited(recipe: recipe2))

		FavoritesHelper.removeFavorite(recipe: recipe)
		XCTAssertFalse(FavoritesHelper.recipeIsFavorited(recipe: recipe))
	}

	func test_addFavorite_existing() {
		let recipe = anyRecipe()

		FavoritesHelper.addFavorite(recipe: recipe)
		FavoritesHelper.addFavorite(recipe: recipe)
		FavoritesHelper.addFavorite(recipe: recipe)

		let favorites = FavoritesHelper.favoriteRecipes(from: [recipe])

		XCTAssertEqual(favorites, [recipe])
	}

	func test_favoriteRecipes() {
		let recipe = anyRecipe()
		let recipe2 = anyRecipe()

		let recipes = [recipe, recipe2]

		XCTAssertTrue(FavoritesHelper.favoriteRecipes(from: recipes).isEmpty)

		FavoritesHelper.addFavorite(recipe: recipe)

		let favorites = FavoritesHelper.favoriteRecipes(from: recipes)

		XCTAssertEqual(favorites, [recipe])
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
}

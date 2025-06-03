//
//  RecipeListModel.swift
//  FetchMobileTHP
//

import SwiftUI

@MainActor
final class RecipeListModel: ObservableObject {
	private var loader: RecipeListLoader?

	@Published
	var recipeItems = [RecipeItem]()

	@Published
	var cuisineTypes = [(type: String, recipes: [RecipeItem])]()

	@Published
	var error: Error?

	func load(with loader: RecipeListLoader?) async {
		guard let loader = loader else {
			return
		}
		self.loader = loader
		let result = await loader.load()
		handleResult(result: result)
	}

	func load() async {
		guard let loader = self.loader else {
			return
		}
		let result = await loader.load()
		handleResult(result: result)
	}

	private func handleResult(result: RecipeListLoader.Result) {
		switch result {
		case let .success(recipeItems):
			self.recipeItems = recipeItems
			let cuisines = Dictionary(grouping: recipeItems) { recipeItem -> String in
				recipeItem.cuisine
			}
			self.cuisineTypes = cuisines.compactMap { cuisineType, items -> (String, [RecipeItem]) in
				return (cuisineType, items)
			}.sorted { $0.0 < $1.0 }
		case let .failure(error):
			self.error = error
		}
	}
}

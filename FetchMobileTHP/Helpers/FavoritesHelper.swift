//
//  FavoritesHelper.swift
//  FetchMobileTHP
//

import Foundation

struct FavoritesHelper {
	private static let FavoritesKey = "favorites"

	static func addFavorite(recipe: RecipeItem) {
		var favorites = UserDefaults.standard.array(forKey: FavoritesKey) as? [String] ?? []
		if favorites.contains(recipe.uuid) {
//			print("Recipe already in favorites.")
			return
		}
		favorites.append(recipe.uuid)
		UserDefaults.standard.setValue(favorites, forKey: FavoritesKey)
//		print("Recipe \(recipe.uuid) has been added to favorites.")
	}

	static func removeFavorite(recipe: RecipeItem) {
		var favorites = UserDefaults.standard.array(forKey: FavoritesKey) as? [String] ?? []
		favorites = favorites.filter { favoriteUUID in
			return favoriteUUID != recipe.uuid
		}
		UserDefaults.standard.setValue(favorites, forKey: FavoritesKey)
//		print("Recipe \(recipe.uuid) has been removed from favorites.")
	}

	static func removeFavorites(at offsets: IndexSet) {
		var favorites = UserDefaults.standard.array(forKey: FavoritesKey) as? [String] ?? []
		favorites.remove(atOffsets: offsets)
		UserDefaults.standard.setValue(favorites, forKey: FavoritesKey)
		//        print("\(offsets.count) favorited recipes have been removed from favorites")
	}

	static func recipeIsFavorited(recipe: RecipeItem) -> Bool {
		guard let favorites = UserDefaults.standard.array(forKey: FavoritesKey) as? [String] else {
			return false
		}
		return favorites.contains(recipe.uuid)
	}

	static func favoriteRecipes(from recipes: [RecipeItem]) -> [RecipeItem] {
		guard let favorites = UserDefaults.standard.array(forKey: FavoritesKey) as? [String] else {
			return []
		}
		return recipes.filter {
			return favorites.contains($0.uuid)
		}
	}
}

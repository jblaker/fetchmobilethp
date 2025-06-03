//
//  RecipeItemsMapper.swift
//  FetchMobileTHP
//

import Foundation

struct RecipeItemsMapper {
	private struct Root: Decodable {
		let recipes: [Item]

		var recipeItems: [RecipeItem] {
			return recipes.map {
				return $0.item
			}
		}
	}

	private struct Item: Decodable {
		let cuisine: String
		let name: String
		let photo_url_large: String?
		let photo_url_small: String?
		let source_url: String?
		let uuid: String
		let youtube_url: String?

		var item: RecipeItem {
			return RecipeItem(cuisine: cuisine, name: name, photo_url_large: photo_url_large, photo_url_small: photo_url_small, source_url: source_url, uuid: uuid, youtube_url: youtube_url)
		}
	}

	private static let OK_200: Int = 200

	static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteRecipeListLoader.Result {
		guard response.statusCode == OK_200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
			return .failure(RemoteRecipeListLoader.Error.invalidData)
		}

		return .success(root.recipeItems)
	}
}

//
//  ImageHelper.swift
//  FetchMobileTHP
//

import Foundation

final class ImageHelper {
	static let shared = ImageHelper()

	private var smallImageCache = [String: Data]()
	private var largeImageCache = [String: Data]()

	enum ImageSize {
		case large
		case small
	}

	static func loadImage(forRecipe recipe: RecipeItem, forSize size: ImageSize, withClient client: HTTPClient) async -> (data: Data, cached: Bool)? {
		guard let urlStr = size == .large ? recipe.photo_url_large : recipe.photo_url_small,
		      let url = URL(string: urlStr) else {
			return nil
		}

		let cache = size == .large ? ImageHelper.shared.largeImageCache : ImageHelper.shared.smallImageCache

		if let cachedData = cache[recipe.uuid] {
//			print("Using cached data for recipe ID \(recipe.uuid) for \(size) size.")
			return (cachedData, true)
		}

		let result = await client.get(from: url)

		switch result {
		case let .success((data, _)):
			switch size {
			case .large:
				ImageHelper.shared.largeImageCache[recipe.uuid] = data
			case .small:
				ImageHelper.shared.smallImageCache[recipe.uuid] = data
			}
			return (data, false)
		case .failure:
			return nil
		}
	}
}

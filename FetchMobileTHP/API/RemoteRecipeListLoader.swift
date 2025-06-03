//
//  RemoteRecipeListLoader.swift
//  FetchMobileTHP
//

import Foundation

public final class RemoteRecipeListLoader: RecipeListLoader {
	private var url: URL
	private let client: HTTPClient

	private static let EndpointURLString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"

	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}

	public typealias Result = RecipeListLoader.Result

	public init(url: URL, client: HTTPClient) {
		self.client = client
		self.url = url
	}

	public func load() async -> Result {
		let result = await client.get(from: url)

		switch result {
		case let .success((data, response)):
			return RecipeItemsMapper.map(data, from: response)
		case .failure:
			return .failure(Error.connectivity)
		}
	}

	public func load(withCompletion completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }

			switch result {
			case let .success((data, response)):
				completion(RecipeItemsMapper.map(data, from: response))
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}

	public static func CreateLoader() -> (any RecipeListLoader)? {
		guard let url = URL(string: EndpointURLString) else {
			return nil
		}
		let client = URLSessionHTTPClient()
		return RemoteRecipeListLoader(url: url, client: client)
	}
}

//
//  RecipeLoader.swift
//  FetchMobileTHP
//

import Foundation

public protocol RecipeListLoader {
	typealias Result = Swift.Result<[RecipeItem], Error>
	func load() async -> Result
	func load(withCompletion completion: @escaping (Result) -> Void)
	static func CreateLoader() -> RecipeListLoader?
}

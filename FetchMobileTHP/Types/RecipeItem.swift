//
//  RecipeItem.swift
//  FetchMobileTHP
//

import Foundation

public struct RecipeItem: Equatable {
	let cuisine: String
	let name: String
	let photo_url_large: String?
	let photo_url_small: String?
	let source_url: String?
	let uuid: String
	let youtube_url: String?
}

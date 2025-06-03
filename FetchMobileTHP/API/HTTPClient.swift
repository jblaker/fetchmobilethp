//
//  HTTPClient.swift
//  FetchMobileTHP
//

import Foundation

public protocol HTTPClient {
	typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>

	func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void)
	func get(from url: URL) async -> HTTPClient.Result
}

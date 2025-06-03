//
//  URLSessionHTTPClient.swift
//  FetchMobileTHP
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
	private let session: URLSession

	public init(session: URLSession = .shared) {
		self.session = session
	}

	private struct UnexpectedValuesRepresentation: Error {}

	public func get(from url: URL) async -> HTTPClient.Result {
		do {
			let (data, response) = try await session.data(from: url)
			if let response = response as? HTTPURLResponse {
				return .success((data, response))
			} else {
				return .failure(UnexpectedValuesRepresentation())
			}
		} catch {
			return .failure(error)
		}
	}

	public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
		session.dataTask(with: url) { data, response, error in
			if let error = error {
				completion(.failure(error))
			} else if let data, let response = response as? HTTPURLResponse {
				completion(.success((data, response)))
			} else {
				completion(.failure(UnexpectedValuesRepresentation()))
			}
		}.resume()
	}
}

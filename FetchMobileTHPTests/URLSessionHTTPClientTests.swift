//
//  URLSessionHTTPClientTests.swift
//  FetchMobileTHPTests
//

import XCTest
@testable import FetchMobileTHP

final class URLSessionHTTPClientTests: XCTestCase {
	override func setUp() {
		super.setUp()
		URLProtocolStub.startInterceptingRequests()
	}

	override func tearDown() {
		super.tearDown()
		URLProtocolStub.stopInterceptingRequests()
	}

	func test_getFromURL_performsGETRequestWithURL() {
		let url = anyURL()
		let exp = expectation(description: "wait for completion")
		URLProtocolStub.observeRequests { request in
			XCTAssertEqual(request.url, url)
			XCTAssertEqual(request.httpMethod, "GET")
			exp.fulfill()
		}

		makeSUT().get(from: url) { _ in }

		wait(for: [exp], timeout: 1)
	}

	func test_getFromURL_failsOnRequestError() {
		let requestError = anyNSError()
		let receivedError = resultError(forData: nil, response: nil, error: requestError)! as NSError

		XCTAssertEqual(receivedError.domain, requestError.domain)
		XCTAssertEqual(receivedError.code, requestError.code)
	}

	func test_getFromURL_failsOnAllInvalidRepresentationCases() {
		XCTAssertNotNil(resultError(forData: nil, response: nil, error: nil))

		XCTAssertNotNil(resultError(forData: nil, response: nonHTTPURLResponse(), error: nil))

		XCTAssertNotNil(resultError(forData: anyData(), response: nil, error: nil))
		XCTAssertNotNil(resultError(forData: anyData(), response: nil, error: anyNSError()))

		XCTAssertNotNil(resultError(forData: nil, response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultError(forData: nil, response: anyHTTPURLResponse(), error: anyNSError()))

		XCTAssertNotNil(resultError(forData: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
		XCTAssertNotNil(resultError(forData: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))

		XCTAssertNotNil(resultError(forData: anyData(), response: nonHTTPURLResponse(), error: nil))
	}

	func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
		let data = anyData()
		let response = anyHTTPURLResponse()
		let receivedValues = resultValues(forData: data, response: response, error: nil)

		XCTAssertEqual(receivedValues!.data, data)
		XCTAssertEqual(receivedValues!.response.url, response!.url)
		XCTAssertEqual(receivedValues!.response.statusCode, response!.statusCode)
	}

	func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
		let response = anyHTTPURLResponse()
		let emptyData = Data()
		let receivedValues = resultValues(forData: emptyData, response: response, error: nil)

		XCTAssertEqual(receivedValues!.data, emptyData)
		XCTAssertEqual(receivedValues!.response.url, response!.url)
		XCTAssertEqual(receivedValues!.response.statusCode, response!.statusCode)
	}

	// MARK: - Helpers

	private func resultError(forData data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
		let result = result(forData: data, response: response, error: error, file: file, line: line)

		switch result {
		case let .failure(error):
			return error
		default:
			XCTFail("Expected failure, got \(result) instead", file: #file, line: #line)
			return nil
		}
	}

	private func resultValues(forData data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
		let result = result(forData: data, response: response, error: error, file: file, line: line)

		switch result {
		case let .success((data, response)):
			return (data, response)
		default:
			XCTFail("Expected success, got \(result) instead", file: file, line: line)
			return nil
		}
	}

	private func result(forData data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
		URLProtocolStub.stub(data: data, response: response, error: error)

		let sut = makeSUT(file: file, line: line)

		let exp = expectation(description: "wait for completion")

		var receivedResult: HTTPClient.Result!
		sut.get(from: anyURL()) { result in
			receivedResult = result
			exp.fulfill()
		}

		wait(for: [exp], timeout: 1)

		return receivedResult
	}

	private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
		let sut = URLSessionHTTPClient()
		trackForMemoryLeaks(sut, file: #file, line: #line)
		return sut
	}

	private func anyURL() -> URL {
		return URL(string: "https://www.apple.com")!
	}

	private func anyData() -> Data {
		return Data("hello".utf8)
	}

	private func anyNSError() -> NSError {
		return NSError(domain: "any error", code: 1)
	}

	private func anyHTTPURLResponse() -> HTTPURLResponse? {
		return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
	}

	private func nonHTTPURLResponse() -> URLResponse {
		return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
	}

	private class URLProtocolStub: URLProtocol {
		private static var stub: Stub?
		private static var requestObserver: ((URLRequest) -> Void?)?

		private struct Stub {
			let data: Data?
			let response: URLResponse?
			let error: Error?
		}

		static func stub(data: Data?, response: URLResponse?, error: Error?) {
			stub = Stub(data: data, response: response, error: error)
		}

		static func observeRequests(observer: @escaping (URLRequest) -> Void) {
			requestObserver = observer
		}

		static func startInterceptingRequests() {
			URLProtocol.registerClass(URLProtocolStub.self)
		}

		static func stopInterceptingRequests() {
			URLProtocol.unregisterClass(URLProtocolStub.self)
			stub = nil
			requestObserver = nil
		}

		override class func canInit(with request: URLRequest) -> Bool {
			return true
		}

		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			return request
		}

		override func startLoading() {
			if let requestObserver = URLProtocolStub.requestObserver {
				client?.urlProtocolDidFinishLoading(self)
				requestObserver(request)
			}

			if let data = URLProtocolStub.stub?.data {
				client?.urlProtocol(self, didLoad: data)
			}

			if let response = URLProtocolStub.stub?.response {
				client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			}

			if let error = URLProtocolStub.stub?.error {
				client?.urlProtocol(self, didFailWithError: error)
			}

			client?.urlProtocolDidFinishLoading(self)
		}

		override func stopLoading() {}
	}
}

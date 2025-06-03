//
//  XCTestCase+Helpers.swift
//  FetchMobileTHPTests
//

import XCTest

extension XCTestCase {
	func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
		addTeardownBlock { [weak instance] in
			XCTAssertNil(instance, "Potential memory leak!", file: file, line: line)
		}
	}
}

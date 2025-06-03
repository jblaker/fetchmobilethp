//
//  FetchMobileTHPApp.swift
//  FetchMobileTHP
//

import SwiftUI

@main
struct FetchMobileTHPApp: App {
	var body: some Scene {
		WindowGroup {
			if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
				RecipeTabView()
			}
		}
	}
}

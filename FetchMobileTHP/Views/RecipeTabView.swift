//
//  RecipeTabView.swift
//  FetchMobileTHP
//

import SwiftUI

struct RecipeTabView: View {
	@StateObject
	var listModel = RecipeListModel()

	var body: some View {
		if let _ = listModel.error {
			VStack(spacing: 15) {
				Text("Error fetching recipes, try again later.")
				Button("Try Again") {
					Task {
						await loadList()
					}
				}
			}
		} else if listModel.recipeItems.count == 0 {
			Text("No Recipes Available.")
				.onAppear() {
					Task {
						await loadList()
					}
				}
		} else {
			TabView {
				CuisineListView()
					.tabItem {
						Label("By Country", systemImage: "list.triangle")
					}
				RecipeListView()
					.tabItem {
						Label("By Name", systemImage: "list.dash")
					}
				FavoriteRecipeListView()
					.tabItem {
						Label("Favorites", systemImage: "list.star")
					}
			}
			.environmentObject(listModel)
		}
	}

	private func loadList() async {
		let loader = RemoteRecipeListLoader.CreateLoader()
		await listModel.load(with: loader)
	}
}

#Preview {
	RecipeTabView()
}

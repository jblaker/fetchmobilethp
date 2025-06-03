//
//  ContentView.swift
//  FetchMobileTHP
//

import SwiftUI

struct RecipeListView: View {
	@EnvironmentObject
	var listModel: RecipeListModel

	@State
	private var searchText = ""

	var body: some View {
		NavigationStack {
			List {
				ForEach(recipes, id: \.uuid) { recipe in
					NavigationLink {
						RecipeDetailsView(recipe: recipe)
					} label: {
						RecipeItemRowView(recipe: recipe)
					}
				}
				.navigationTitle("Recipes")
			}
			.refreshable {
				await loadList()
			}
		}
		.searchable(text: $searchText)
	}

	private var recipes: [RecipeItem] {
		if searchText.isEmpty {
			return listModel.recipeItems
		} else {
			return listModel.recipeItems.filter { $0.name.lowercased().contains(searchText.lowercased()) }
		}
	}

	private func loadList() async {
		await listModel.load()
	}
}

#Preview {
	let model = RecipeListModel()
	RecipeListView().environmentObject(model)
}

struct FilteredRecipeListView: View {
	let section: (type: String, recipes: [RecipeItem])

	var body: some View {
		NavigationStack {
			List {
				ForEach(section.recipes, id: \.uuid) { recipe in
					NavigationLink {
						RecipeDetailsView(recipe: recipe)
					} label: {
						RecipeItemRowView(recipe: recipe)
					}
				}
			}
			.navigationTitle(section.type)
		}
	}
}

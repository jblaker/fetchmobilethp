//
//  CuisineListView.swift
//  FetchMobileTHP
//

import SwiftUI

struct CuisineListView: View {
	@EnvironmentObject
	var listModel: RecipeListModel

	@State
	private var favoriteRecipes: [RecipeItem]?

	var body: some View {
		NavigationStack {
			List {
				ForEach(listModel.cuisineTypes, id: \.type) { section in
					NavigationLink {
						FilteredRecipeListView(section: section)
					} label: {
						VStack(alignment: .leading) {
							Text("\(section.type)")
								.font(.headline)
							recipeCountLabel(count: section.recipes.count)
						}
					}
				}
			}
			.refreshable {
				await loadList()
			}
			.navigationTitle("Countries")
		}
	}

	private func loadList() async {
		await listModel.load()
	}

	private func recipeCountLabel(count: Int) -> Text {
		let verbiage = count == 1 ? "recipe" : "recipes"
		return Text("\(count) \(verbiage)")
	}
}

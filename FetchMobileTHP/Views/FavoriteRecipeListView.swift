//
//  FavoriteRecipeListView.swift
//  FetchMobileTHP
//

import SwiftUI

struct FavoriteRecipeListView: View {
	@EnvironmentObject
	var listModel: RecipeListModel

	@State
	private var favoriteRecipes: [RecipeItem]?

	var body: some View {
		NavigationStack {
			if let favoriteRecipes, favoriteRecipes.count > 0 {
				List {
					ForEach(favoriteRecipes, id: \.uuid) { recipe in
						NavigationLink {
							RecipeDetailsView(recipe: recipe)
						} label: {
							RecipeItemRowView(recipe: recipe)
						}
					}.onDelete(perform: delete)
				}
				.navigationTitle("Favorite Recipes")
			} else {
				Text("No Recipes Have Been Favorited.")
			}
		}.onAppear {
			favoriteRecipes = FavoritesHelper.favoriteRecipes(from: listModel.recipeItems)
		}
	}

	private func delete(at offsets: IndexSet) {
		FavoritesHelper.removeFavorites(at: offsets)
	}
}

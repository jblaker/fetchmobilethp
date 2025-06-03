//
//  RecipeDetailsView.swift
//  FetchMobileTHP
//

import SwiftUI

struct RecipeDetailsView: View {
	let recipe: RecipeItem

	@State
	private var imageData: Data?

	@State
	private var favorited = false

	private let imageHeight = 175.0

	var body: some View {
		NavigationStack {
			VStack(alignment: .leading, spacing: 15) {
				ZStack(alignment: .topLeading) {
					if let imageData, let image = UIImage(data: imageData) {
						Image(uiImage: image)
							.resizable()
							.aspectRatio(contentMode: .fill)
							.frame(height: imageHeight)
							.clipped()
					} else {
						Rectangle()
							.fill(.gray)
							.frame(height: imageHeight)
					}
					VStack(alignment: .leading) {
						VStack(alignment: .leading) {
							Text(recipe.name)
								.font(.title)
								.foregroundColor(.white)
								.shadow(color: .black, radius: 0.0, x: 1, y: 1)
							Text(recipe.cuisine)
								.font(.title2)
								.foregroundColor(.white)
								.shadow(color: .black, radius: 0.0, x: 1, y: 1)
						}
						.padding()
						Spacer()
						HStack(spacing: 15) {
							if let source_url = recipe.source_url, let url = URL(string: source_url) {
								Button("View On Site") {
									UIApplication.shared.open(url)
								}
								.padding()
								Spacer()
							}

							if let youtube_url = recipe.youtube_url, let url = URL(string: youtube_url) {
								Button("View on YouTube") {
									UIApplication.shared.open(url)
								}
								.padding()
							}
						}
						.background(.white.opacity(0.75))
					}
					.frame(height: imageHeight)
				}
				Spacer()
			}
			.navigationTitle("Details")
			.toolbar {
				ToolbarItem {
					Button {
						toggleFavorite()
					} label: {
						if favorited {
							Image(systemName: "star.fill")
						} else {
							Image(systemName: "star")
						}
					}
				}
			}
		}
		.onAppear {
			checkIfFavorited()
			Task {
				let client = URLSessionHTTPClient()
				let result = await ImageHelper.loadImage(forRecipe: recipe, forSize: .large, withClient: client)
				imageData = result?.data
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}

	private func toggleFavorite() {
		if favorited {
			FavoritesHelper.removeFavorite(recipe: recipe)
		} else {
			FavoritesHelper.addFavorite(recipe: recipe)
		}
		checkIfFavorited()
	}

	private func checkIfFavorited() {
		favorited = FavoritesHelper.recipeIsFavorited(recipe: recipe)
	}
}

#Preview {
	let recipe = RecipeItem(
		cuisine: "Malaysian",
		name: "Apam Balik",
		photo_url_large: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
		photo_url_small: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
		source_url: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
		uuid: "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
		youtube_url: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
	)
	return RecipeDetailsView(recipe: recipe)
}

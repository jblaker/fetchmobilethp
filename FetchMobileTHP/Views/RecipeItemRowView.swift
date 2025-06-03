//
//  RecipeListRowView.swift
//  FetchMobileTHP
//

import SwiftUI

struct RecipeItemRowView: View {
	let recipe: RecipeItem

	@State
	private var imageData: Data?

	var body: some View {
		HStack() {
			if let imageData, let image = UIImage(data: imageData) {
				Image(uiImage: image)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 50, height: 50)
			} else {
				VStack {
					ProgressView()
				}
				.frame(width: 50, height: 50)
			}
			Text("\(recipe.name)")
				.font(.headline)
		}
		.onAppear {
			Task {
				let client = URLSessionHTTPClient()
				let result = await ImageHelper.loadImage(forRecipe: recipe, forSize: .small, withClient: client)
				imageData = result?.data
			}
		}
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
	RecipeItemRowView(recipe: recipe)
}

//
//  DinnerItemGeneration.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 16/10/2025.
//

import Foundation
import FoundationModels

@Generable
struct DinnerItemGeneration: Codable {
    @Guide(description: "The name of the recipe, should be descriptive and appetizing")
    var name: String
    @Guide(description: "A brief description of the dish, its flavors, and what makes it special")
    var description: String
    @Guide(description: "Time needed to prepare ingredients in minutes")
    var prepTime: Int
    @Guide(description: "Time needed to cook the dish in minutes")
    var cookTime: Int
    @Guide(description: "Step-by-step cooking instructions, each with a title and detailed description")
    var steps: [DinnerItemStepGeneration]
    @Guide(description: "Relevant food tags that describe the dish characteristics")
    var tags: [FoodTag]
}

@Generable
struct DinnerItemStepGeneration: Codable {
    @Guide(description: "A short, clear title for this cooking step")
    var stepTitle: String
    @Guide(description: "Detailed instructions for completing this step of the recipe")
    var stepDescription: String
}

extension DinnerItemGeneration {
    static var sampleItem: DinnerItemGeneration {
        return DinnerItemGeneration(
            name: "Spaghetti Bolognese",
            description: "A classic Italian pasta dish with rich meat sauce.",
            prepTime: 15,
            cookTime: 45,
            steps: [
                DinnerItemStepGeneration(
                    stepTitle: "Boil pasta",
                    stepDescription: "Cook pasta in salted boiling water until al dente."
                ),
                DinnerItemStepGeneration(
                    stepTitle: "Prepare sauce",
                    stepDescription: "Sauté onions, garlic, and ground beef, then add tomatoes and simmer."
                )
            ],
            tags: [.FamilyFriendly, .Cheap, .Vegan]
        )
    }
}
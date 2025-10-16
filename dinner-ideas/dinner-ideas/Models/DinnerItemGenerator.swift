//
//  DinnerItemGenerator.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 16/10/2025.
//

import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class DinnerItemGenerator {
    
    var error: Error?
    
    private var session: LanguageModelSession
    
    private(set) var generatedItem: DinnerItemGeneration.PartiallyGenerated?
    
    // Array of recipe types for better generation variety
    private static let recipeTypes: [String] = [
        // Italian
        "Spaghetti Carbonara", "Margherita Pizza", "Lasagna Bolognese", "Chicken Parmigiana", "Fettuccine Alfredo",
        "Risotto Milanese", "Osso Buco", "Tiramisu", "Bruschetta", "Caprese Salad", "Minestrone Soup", "Gnocchi Pomodoro",
        
        // Asian
        "Pad Thai", "Chicken Teriyaki", "Beef and Broccoli", "Fried Rice", "Ramen Noodles", "Sushi Rolls",
        "General Tso's Chicken", "Sweet and Sour Pork", "Kung Pao Chicken", "Ma Po Tofu", "Korean BBQ",
        "Bibimbap", "Pho Bo", "Thai Green Curry", "Yakitori", "Tempura Vegetables", "Miso Soup", "Dumplings",
        
        // Mexican
        "Chicken Tacos", "Beef Enchiladas", "Guacamole", "Quesadillas", "Burrito Bowl", "Chiles Rellenos",
        "Tamales", "Fajitas", "Carnitas", "Pozole", "Elote", "Churros", "Tres Leches Cake",
        
        // American
        "Hamburger", "BBQ Ribs", "Mac and Cheese", "Fried Chicken", "Clam Chowder", "Buffalo Wings",
        "Meatloaf", "Apple Pie", "Pancakes", "Cornbread", "Pulled Pork", "Coleslaw", "Banana Bread",
        
        // French
        "Coq au Vin", "Beef Bourguignon", "Ratatouille", "French Onion Soup", "Bouillabaisse", "Quiche Lorraine",
        "Croque Monsieur", "Escargot", "Duck Confit", "Crème Brûlée", "Soufflé", "Cassoulet",
        
        // Indian
        "Butter Chicken", "Chicken Tikka Masala", "Biryani", "Samosas", "Naan Bread", "Dal Curry",
        "Tandoori Chicken", "Palak Paneer", "Vindaloo", "Chana Masala", "Korma", "Raita",
        
        // Mediterranean
        "Greek Salad", "Moussaka", "Hummus", "Falafel", "Shawarma", "Tabbouleh", "Dolmades",
        "Baklava", "Spanakopita", "Tzatziki", "Kebabs", "Paella",
        
        // British
        "Fish and Chips", "Shepherd's Pie", "Bangers and Mash", "Beef Wellington", "Chicken Tikka",
        "Full English Breakfast", "Yorkshire Pudding", "Spotted Dick", "Toad in the Hole",
        
        // German
        "Schnitzel", "Sauerbraten", "Bratwurst", "Sauerkraut", "Pretzels", "Black Forest Cake",
        "Spätzle", "Currywurst", "Strudel",
        
        // Comfort Foods
        "Chicken Soup", "Grilled Cheese Sandwich", "Tomato Soup", "Mashed Potatoes", "Pot Roast",
        "Chili Con Carne", "Beef Stew", "Chicken and Dumplings", "Tuna Casserole", "Meatballs",
        
        // Healthy Options
        "Quinoa Salad", "Avocado Toast", "Smoothie Bowl", "Kale Caesar Salad", "Grilled Salmon",
        "Vegetable Stir Fry", "Buddha Bowl", "Lentil Soup", "Chickpea Curry", "Zucchini Noodles",
        
        // Breakfast/Brunch
        "French Toast", "Eggs Benedict", "Breakfast Burrito", "Waffles", "Omelette", "Breakfast Hash",
        "Granola Parfait", "Breakfast Sandwich", "Breakfast Pizza", "Shakshuka",
        
        // Desserts
        "Chocolate Chip Cookies", "Brownies", "Cheesecake", "Ice Cream", "Fruit Tart", "Lemon Bars",
        "Carrot Cake", "Red Velvet Cake", "Panna Cotta", "Mousse", "Macarons", "Donuts"
    ]
    
    init() {
        let instructions = Instructions {
            """
            Your job is to create a recipe item for the user to cook. 
            Define each step in the preparing and cooking process.
            
            You can choose from a wide variety of recipe types including Italian, Asian, Mexican, 
            American, French, Indian, Mediterranean, British, German, comfort foods, healthy options, 
            breakfast/brunch items, and desserts. Create recipes that are inspired by these cuisines 
            but with your own creative variations.
            
            Make sure to:
            - Create a descriptive and appetizing recipe name
            - Provide a clear description of the dish, its flavors, and what makes it special
            - Include realistic preparation and cooking times (prep: 5-60 minutes, cook: 10-180 minutes)
            - Break down the cooking process into clear, detailed steps (3-8 steps typically)
            - Assign appropriate food tags that describe the dish characteristics
            - Each step should have a clear title and detailed instructions
            - Consider dietary restrictions and cooking skill levels
            - Make the recipe practical for home cooking
            """
        }
        
        self.session = LanguageModelSession(instructions: instructions)
    }
    
    func generateRecipe(name: String = "") async {
        do {
            let sampleData = DinnerItemGeneration.sampleItem
            let sampleJSON = try JSONEncoder().encode(sampleData)
            let sampleString = String(data: sampleJSON, encoding: .utf8) ?? ""
            
            // Pick a random recipe type for inspiration if no name provided
            let randomRecipeType = Self.recipeTypes.randomElement() ?? "Classic Home-Cooked Meal"
            
            let prompt = Prompt {
                if !name.isEmpty {
                    "Generate a recipe for: \(name)"
                } else {
                    "Generate a recipe inspired by or variations of \"\(randomRecipeType)\". You can create your own unique version, fusion style, or creative interpretation of this dish type."
                }
                "Here is an example of the desired format, but don't copy its content:"
                sampleString
            }
            
            let stream = session.streamResponse(to: prompt,
                                                generating: DinnerItemGeneration.self,
                                                includeSchemaInPrompt: false)
            
            for try await partialResponse in stream {
                self.generatedItem = partialResponse.content
            }
            
        } catch {
            self.error = error
        }
    }
    
    func prewarmModel() {
        session.prewarm(promptPrefix: Prompt {
            "Generate a recipe that someone can follow the instructions of"
        })
    }
    
    func reset() {
        generatedItem = nil
        error = nil
    }
    
    func convertToFinalItem() -> DinnerItem? {
        guard let generated = generatedItem,
              let name = generated.name,
              let description = generated.description,
              let prepTime = generated.prepTime,
              let cookTime = generated.cookTime,
              let steps = generated.steps,
              let tags = generated.tags else {
            return nil
        }
        
        // Convert generation steps to proper DinnerItemStep instances with UUIDs
        let finalSteps = steps.map { step in
            DinnerItemStep(
                stepTitle: step.stepTitle ?? "",
                stepDescription: step.stepDescription ?? ""
            )
        }
        
        return DinnerItem(
            createdBy: 1,
            lastModifiedBy: 1,
            createdDate: Date(),
            lastModifiedDate: Date(),
            id: UUID(),
            name: name,
            description: description,
            prepTime: prepTime,
            cookTime: cookTime,
            steps: finalSteps,
            tags: tags,
            image: ""
        )
    }
}

//
//  FoodTag.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 29/01/2025.
//

import SwiftUI
import FoundationModels

@Generable
enum FoodTag: String, CaseIterable, Identifiable, Codable {
    case Quick
    case Vegeterian
    case Vegan
    case GlutenFree
    case Cheap
    case LowCarb
    case FamilyFriendly
   
    var id: String { self.rawValue }
    
    var name: String {
        switch self {
        case .Quick:
            return "Quick"
        case .Vegeterian:
            return "Vegetarian"
        case .Vegan:
            return "Vegan"
        case .GlutenFree:
            return "Gluten Free"
        case .Cheap:
            return "Cheap"
        case .LowCarb:
            return "Low Carb"
        case .FamilyFriendly:
            return "Family Friendly"
        }
    }
    
    var color: Color {
        switch self {
        case .Quick:
            return .blue
        case .Vegeterian:
            return .green
        case .Vegan:
            return .mint
        case .GlutenFree:
            return .yellow
        case .Cheap:
            return .orange
        case .LowCarb:
            return .red
        case .FamilyFriendly:
            return .pink
        }
    }
}

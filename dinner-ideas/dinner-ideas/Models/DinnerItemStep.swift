//
//  DinnerItemStep.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 29/01/2025.
//
import Foundation

struct DinnerItemStep : Identifiable, Codable {
    var stepTitle: String
    var stepDescription: String
    let id: UUID
    
    init(stepTitle: String, stepDescription: String) {
        self.stepTitle = stepTitle
        self.stepDescription = stepDescription
        self.id = UUID()
    }
}

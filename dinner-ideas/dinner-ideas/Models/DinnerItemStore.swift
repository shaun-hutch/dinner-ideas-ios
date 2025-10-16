//
//  DinnerItemStore.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 29/01/2025.
//

import SwiftUI

@MainActor
class DinnerItemStore: ObservableObject {
    @Published var savedItems: [DinnerItem] = []
    @Published var generatedItems: [DinnerItemGeneratedWeek] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        ).appendingPathComponent("dinner-items.json")
    }
    
    func load() async throws {
        let task = Task<[DinnerItem], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return DinnerItem.sampleItems
            }
            
            let dinnerItems = try JSONDecoder().decode([DinnerItem].self, from: data)
            
            return dinnerItems
        }
        
        let items = try await task.value
        self.savedItems = items
    }
    
    func save(items: [DinnerItem]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(items)
            let fileURL = try Self.fileURL()
            try! data.write(to: fileURL)
        }
        
        _ = try await task.value
    }
}

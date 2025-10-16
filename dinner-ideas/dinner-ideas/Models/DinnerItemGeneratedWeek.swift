//
//  DinnerItemGeneratedWeek.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 18/03/2025.
//

import Foundation

struct DinnerItemGeneratedWeek: Identifiable, Codable {
    var id: UUID
    var itemIds: [UUID]
    
    init(id: UUID = UUID(), itemIds: [UUID] = []) {
        self.id = id
        self.itemIds = itemIds
    }
}

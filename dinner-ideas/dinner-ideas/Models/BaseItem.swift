//
//  BaseItem.swift
//  dinner-ideas
//
//  Created by Shaun Hutchinson on 29/01/2025.
//

import Foundation

protocol BaseItem : Identifiable, Codable {
    var typeAndId: String { get }
    var id: UUID { get set }
    var createdBy: Int { get set }
    var lastModifiedBy: Int { get set }
    var createdDate: Date { get set }
    var lastModifiedDate: Date { get set }
    var version: Int? { get set }
}

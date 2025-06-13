//
//  CharacterOption.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import Foundation

// MARK: - Character Option Model
struct CharacterOption: Codable, Identifiable, Hashable {
    let id: Int
    let categoryId: Int
    let value: String
    let description: String?
    let metadata: [String: String]?
    let isDefault: Bool?
    let displayOrder: Int?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case value
        case description
        case metadata
        case isDefault = "is_default"
        case displayOrder = "display_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

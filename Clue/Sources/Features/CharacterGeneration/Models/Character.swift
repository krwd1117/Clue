//
//  Character.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import Foundation

// MARK: - Character Model
struct Character: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: String?
    let name: String
    let selectedOptions: [String: String]? // categoryId: optionValue 매핑 (Edge Function과 일치)
    let gender: String?
    let age: String?
    let appearance: String?
    let backstory: String?
    let conflict: String?
    let narrative: String?
    let description: String? // 호환성을 위해 유지
    let imageUrl: String?
    let metadata: [String: String]?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case selectedOptions = "selected_options"
        case gender
        case age
        case appearance
        case backstory
        case conflict
        case narrative
        case description
        case imageUrl = "image_url"
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

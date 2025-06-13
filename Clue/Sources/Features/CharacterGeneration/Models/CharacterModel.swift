import Foundation

// MARK: - Character Category Model
struct CharacterCategory: Codable, Identifiable, Hashable {
    let id: Int
    let stepOrder: Int?
    let name: String
    let description: String?
    let metadata: [String: String]?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case stepOrder = "step_order"
        case name
        case description
        case metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Character Option Model
struct CharacterOption: Codable, Identifiable, Hashable {
    let id: Int
    let categoryId: Int
    let value: String
    let metadata: [String: String]?
    let isDefault: Bool?
    let displayOrder: Int?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryId = "category_id"
        case value
        case metadata
        case isDefault = "is_default"
        case displayOrder = "display_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Character Model
struct Character: Codable, Identifiable, Hashable {
    let id: Int?
    let userId: String?
    let name: String
    let selectedOptions: [Int: Int]? // categoryId: optionId 매핑
    let description: String?
    let imageUrl: String?
    let createdAt: Date?
    let updatedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case selectedOptions = "selected_options"
        case description
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Character Creation Request
struct CharacterCreateRequest: Codable {
    let name: String
    let selectedOptions: [Int: Int] // categoryId: optionId 매핑
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case selectedOptions = "selected_options"
        case description
    }
}

// MARK: - Category Selection State
struct CategorySelection {
    let category: CharacterCategory
    let selectedOption: CharacterOption?
    
    var isComplete: Bool {
        selectedOption != nil
    }
} 
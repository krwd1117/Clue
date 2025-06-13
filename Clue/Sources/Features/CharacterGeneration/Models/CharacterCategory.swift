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

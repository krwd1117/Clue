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
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // 기본 필드들
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        age = try container.decodeIfPresent(String.self, forKey: .age)
        appearance = try container.decodeIfPresent(String.self, forKey: .appearance)
        backstory = try container.decodeIfPresent(String.self, forKey: .backstory)
        conflict = try container.decodeIfPresent(String.self, forKey: .conflict)
        narrative = try container.decodeIfPresent(String.self, forKey: .narrative)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        // selectedOptions - 안전한 JSON 파싱
        selectedOptions = Self.safeDecodeJSONDictionary(from: container, forKey: .selectedOptions)
        
        // metadata - 안전한 JSON 파싱
        metadata = Self.safeDecodeJSONDictionary(from: container, forKey: .metadata)
    }
    
    // MARK: - Custom Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(selectedOptions, forKey: .selectedOptions)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(age, forKey: .age)
        try container.encodeIfPresent(appearance, forKey: .appearance)
        try container.encodeIfPresent(backstory, forKey: .backstory)
        try container.encodeIfPresent(conflict, forKey: .conflict)
        try container.encodeIfPresent(narrative, forKey: .narrative)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(imageUrl, forKey: .imageUrl)
        try container.encodeIfPresent(metadata, forKey: .metadata)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
    
    // MARK: - Helper Methods
    private static func safeDecodeJSONDictionary(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> [String: String]? {
        // 1. 먼저 Dictionary로 직접 디코딩 시도
        if let dict = try? container.decodeIfPresent([String: String].self, forKey: key) {
            return dict
        }
        
        // 2. String으로 디코딩 후 JSON 파싱 시도
        if let jsonString = try? container.decodeIfPresent(String.self, forKey: key),
           !jsonString.isEmpty {
            
            // 빈 객체나 null 체크
            let trimmed = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed == "{}" || trimmed == "null" || trimmed == "NULL" {
                return nil
            }
            
            // JSON 파싱 시도
            if let data = jsonString.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                
                // 모든 값을 String으로 변환
                var stringDict: [String: String] = [:]
                for (k, v) in dict {
                    if let stringValue = v as? String {
                        stringDict[k] = stringValue
                    } else {
                        stringDict[k] = String(describing: v)
                    }
                }
                return stringDict.isEmpty ? nil : stringDict
            }
        }
        
        // 3. 모든 시도가 실패하면 nil 반환 (오류 대신)
        print("⚠️ Failed to decode JSON dictionary for key: \(key), returning nil")
        return nil
    }
    
    // MARK: - Convenience Initializer
    init(
        id: Int? = nil,
        userId: String? = nil,
        name: String,
        selectedOptions: [String: String]? = nil,
        gender: String? = nil,
        age: String? = nil,
        appearance: String? = nil,
        backstory: String? = nil,
        conflict: String? = nil,
        narrative: String? = nil,
        description: String? = nil,
        imageUrl: String? = nil,
        metadata: [String: String]? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.userId = userId
        self.name = name
        self.selectedOptions = selectedOptions
        self.gender = gender
        self.age = age
        self.appearance = appearance
        self.backstory = backstory
        self.conflict = conflict
        self.narrative = narrative
        self.description = description
        self.imageUrl = imageUrl
        self.metadata = metadata
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

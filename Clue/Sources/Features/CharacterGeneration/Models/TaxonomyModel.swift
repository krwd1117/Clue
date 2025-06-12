//
//  TaxonomyModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation

// MARK: - Taxonomy 데이터 모델
struct TaxonomyItem: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let category: TaxonomyCategory
    let parentId: Int?
    let sortOrder: Int
    
    private enum CodingKeys: String, CodingKey {
        case id, name, category
        case parentId = "parent_id"
        case sortOrder = "sort_order"
    }
    
    // UI 표시용 설명 (기본적으로 name을 그대로 사용)
    var description: String {
        return name
    }
}

// MARK: - Taxonomy 카테고리
enum TaxonomyCategory: String, Codable, CaseIterable {
    case genre = "장르"
    case theme = "테마"
    case era = "시대"
    case mood = "분위기"
    case personality = "성격"
    case origin = "출신"
    case weakness = "약점"
    case motivation = "동기"
    case goal = "목표"
    case twist = "반전"
    
    var displayName: String {
        return self.rawValue
    }
    
    var description: String {
        switch self {
        case .genre: return "어떤 세계관인가요?"
        case .theme: return "어떤 주제를 다루고 싶나요?"
        case .era: return "언제 시대인가요?"
        case .mood: return "어떤 분위기인가요?"
        case .personality: return "어떤 성격인가요?"
        case .origin: return "어디 출신인가요?"
        case .weakness: return "어떤 약점이 있나요?"
        case .motivation: return "무엇이 동기인가요?"
        case .goal: return "무엇을 목표로 하나요?"
        case .twist: return "어떤 반전이 있나요?"
        }
    }
    
    // 커스텀 디코딩을 위한 초기화
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        
        switch rawValue {
        case "장르": self = .genre
        case "테마": self = .theme
        case "시대": self = .era
        case "분위기": self = .mood
        case "성격": self = .personality
        case "출신": self = .origin
        case "약점": self = .weakness
        case "동기": self = .motivation
        case "목표": self = .goal
        case "반전": self = .twist
        default:
            print("⚠️ Unknown category: \(rawValue), defaulting to genre")
            self = .genre // 알 수 없는 값은 기본값으로 설정
        }
    }
}

// MARK: - Taxonomy 그룹 (UI 표시용)
struct TaxonomyGroup {
    let category: TaxonomyCategory
    let items: [TaxonomyItem]
    
    var displayName: String {
        category.displayName
    }
    
    var description: String {
        category.description
    }
}

// MARK: - 캐릭터 생성 설정 (동적 버전)
struct DynamicCharacterSettings: Codable, Hashable {
    let genreId: Int
    let themeId: Int
    let eraId: Int
    let moodId: Int
    let personalityId: Int
    let originId: Int
    let weaknessId: Int
    let motivationId: Int
    let goalId: Int
    let twistId: Int
    
    // 디스플레이용 (실제 taxonomy 아이템들)
    var genre: TaxonomyItem?
    var theme: TaxonomyItem?
    var era: TaxonomyItem?
    var mood: TaxonomyItem?
    var personality: TaxonomyItem?
    var origin: TaxonomyItem?
    var weakness: TaxonomyItem?
    var motivation: TaxonomyItem?
    var goal: TaxonomyItem?
    var twist: TaxonomyItem?
}

// MARK: - Supabase 응답 모델
struct TaxonomyResponse: Codable {
    let data: [TaxonomyItem]?
    let error: SupabaseError?
}

struct SupabaseError: Codable {
    let message: String
    let details: String?
    let hint: String?
    let code: String?
} 
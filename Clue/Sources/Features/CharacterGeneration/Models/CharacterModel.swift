//
//  CharacterModel.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation

// MARK: - 생성된 캐릭터 모델
struct GeneratedCharacter: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let age: String
    let appearance: String
    let backstory: String
    let conflict: String
    let createdAt: Date
    
    // 메타데이터 (선택사항)
    let modelUsed: String?
    let tokensUsed: Int?
    // generationSettings는 추후 필요시 추가
    
    init(name: String, age: String, appearance: String, backstory: String, conflict: String, 
         modelUsed: String? = nil, tokensUsed: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.age = age
        self.appearance = appearance
        self.backstory = backstory
        self.conflict = conflict
        self.createdAt = Date()
        self.modelUsed = modelUsed
        self.tokensUsed = tokensUsed
    }
    
    // 데이터베이스에서 로드할 때 사용하는 초기화
    init(id: UUID, name: String, age: String, appearance: String, backstory: String, conflict: String,
         createdAt: Date, modelUsed: String? = nil, tokensUsed: Int? = nil) {
        self.id = id
        self.name = name
        self.age = age
        self.appearance = appearance
        self.backstory = backstory
        self.conflict = conflict
        self.createdAt = createdAt
        self.modelUsed = modelUsed
        self.tokensUsed = tokensUsed
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, name, age, appearance, backstory, conflict
        case createdAt = "created_at"
        case modelUsed = "model_used"
        case tokensUsed = "tokens_used"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(String.self, forKey: .age)
        appearance = try container.decode(String.self, forKey: .appearance)
        backstory = try container.decode(String.self, forKey: .backstory)
        conflict = try container.decode(String.self, forKey: .conflict)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        modelUsed = try container.decodeIfPresent(String.self, forKey: .modelUsed)
        tokensUsed = try container.decodeIfPresent(Int.self, forKey: .tokensUsed)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(appearance, forKey: .appearance)
        try container.encode(backstory, forKey: .backstory)
        try container.encode(conflict, forKey: .conflict)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(modelUsed, forKey: .modelUsed)
        try container.encodeIfPresent(tokensUsed, forKey: .tokensUsed)
    }
}

// MARK: - 캐릭터 생성 설정 모델
struct CharacterSettings: Codable, Hashable
{
    let genre: CharacterGenre
    let theme: CharacterTheme
    let background: CharacterBackground
}

// MARK: - 향상된 캐릭터 생성 설정 모델 (문자열 기반)
struct EnhancedCharacterSettings: Codable, Hashable {
    let genre: String
    let theme: String
    let era: String
    let mood: String
    let personality: String
    let origin: String
    let weakness: String
    let motivation: String
    let goal: String
    let twist: String
}

// MARK: - 장르 열거형
enum CharacterGenre: String, CaseIterable, Codable {
    case fantasy = "fantasy"
    case sciFi = "sci-fi"
    case romance = "romance"
    case mystery = "mystery"
    case horror = "horror"
    case historical = "historical"
    case modern = "modern"
    case cyberpunk = "cyberpunk"
    
    var displayName: String {
        switch self {
        case .fantasy: return "판타지"
        case .sciFi: return "SF"
        case .romance: return "로맨스"
        case .mystery: return "추리"
        case .horror: return "호러"
        case .historical: return "역사"
        case .modern: return "현대"
        case .cyberpunk: return "사이버펑크"
        }
    }
    
    var description: String {
        switch self {
        case .fantasy: return "마법과 신화의 세계"
        case .sciFi: return "미래와 과학 기술"
        case .romance: return "사랑과 관계"
        case .mystery: return "수수께끼와 추리"
        case .horror: return "공포와 서스펜스"
        case .historical: return "과거의 시대"
        case .modern: return "현재의 일상"
        case .cyberpunk: return "디지털 미래 사회"
        }
    }
}

// MARK: - 테마 열거형
enum CharacterTheme: String, CaseIterable, Codable {
    case redemption = "redemption"
    case revenge = "revenge"
    case love = "love"
    case sacrifice = "sacrifice"
    case discovery = "discovery"
    case survival = "survival"
    case betrayal = "betrayal"
    case power = "power"
    
    var displayName: String {
        switch self {
        case .redemption: return "구원"
        case .revenge: return "복수"
        case .love: return "사랑"
        case .sacrifice: return "희생"
        case .discovery: return "발견"
        case .survival: return "생존"
        case .betrayal: return "배신"
        case .power: return "권력"
        }
    }
    
    var description: String {
        switch self {
        case .redemption: return "잃어버린 것을 되찾는 여정"
        case .revenge: return "복수를 위한 투쟁"
        case .love: return "진정한 사랑을 찾아서"
        case .sacrifice: return "소중한 것을 위한 희생"
        case .discovery: return "새로운 진실의 발견"
        case .survival: return "극한 상황에서의 생존"
        case .betrayal: return "믿음과 배신의 갈등"
        case .power: return "권력을 둘러싼 투쟁"
        }
    }
}

// MARK: - 배경 열거형
enum CharacterBackground: String, CaseIterable, Codable {
    case medievalKingdom = "medieval-kingdom"
    case modernCity = "modern-city"
    case spaceStation = "space-station"
    case magicAcademy = "magic-academy"
    case postApocalyptic = "post-apocalyptic"
    case victorianEra = "victorian-era"
    case cyberpunkCity = "cyberpunk-city"
    case pirateSea = "pirate-sea"
    
    var displayName: String {
        switch self {
        case .medievalKingdom: return "중세 왕국"
        case .modernCity: return "현대 도시"
        case .spaceStation: return "우주 정거장"
        case .magicAcademy: return "마법 학원"
        case .postApocalyptic: return "포스트 아포칼립스"
        case .victorianEra: return "빅토리아 시대"
        case .cyberpunkCity: return "사이버펑크 도시"
        case .pirateSea: return "해적의 바다"
        }
    }
    
    var description: String {
        switch self {
        case .medievalKingdom: return "기사와 마법사가 존재하는 왕국"
        case .modernCity: return "현재의 도시 환경"
        case .spaceStation: return "우주 공간의 거대한 정거장"
        case .magicAcademy: return "마법을 배우는 학교"
        case .postApocalyptic: return "문명이 붕괴된 세계"
        case .victorianEra: return "19세기 영국의 우아한 시대"
        case .cyberpunkCity: return "네온사인과 AI가 지배하는 도시"
        case .pirateSea: return "보물과 모험이 가득한 바다"
        }
    }
}

// MARK: - ChatGPT API 요청 모델
struct CharacterGenerationRequest: Codable {
    let model: String = "gpt-3.5-turbo"
    let messages: [ChatMessage]
    let maxTokens: Int = 500
    let temperature: Double = 0.8
    
    private enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

struct ChatMessage: Codable {
    let role: String
    let content: String
}

// MARK: - ChatGPT API 응답 모델
struct CharacterGenerationResponse: Codable {
    let choices: [ChatChoice]
}

struct ChatChoice: Codable {
    let message: ChatMessage
}

// MARK: - Edge Function 요청/응답 모델
struct EdgeFunctionRequest: Codable {
    let systemMessage: String
    let userMessage: String
    let maxTokens: Int
    let temperature: Double
    
    private enum CodingKeys: String, CodingKey {
        case systemMessage = "system_message"
        case userMessage = "user_message"
        case maxTokens = "max_tokens"
        case temperature
    }
}

struct EdgeFunctionResponse: Codable {
    let success: Bool
    let character: EdgeCharacterData
    let error: String?
    let metadata: EdgeMetadata?
    let timestamp: String?
}

struct EdgeMetadata: Codable {
    let model: String?
    let usage: OpenAIUsage?
    let timestamp: String?
}

struct OpenAIUsage: Codable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?
    
    private enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

struct EdgeCharacterData: Codable {
    let name: String
    let age: String
    let appearance: String
    let backstory: String
    let conflict: String
} 

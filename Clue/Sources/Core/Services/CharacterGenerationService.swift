//
//  CharacterGenerationService.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import Foundation

// MARK: - 캐릭터 생성 서비스
class CharacterGenerationService: ObservableObject {
    static let shared = CharacterGenerationService()
    
    private init() {}
    
    // MARK: - 동적 캐릭터 생성 메서드 (10개 카테고리)
    
    func generateDynamicCharacter(with settings: DynamicCharacterSettings) async throws -> GeneratedCharacter {
        print("🎭 CharacterGenerationService: Generating dynamic character with 10 categories")
        
        let prompt = createDynamicPrompt(for: settings)
        let request = CharacterGenerationRequest(
            messages: [
                ChatMessage(role: "system", content: "당신은 창작자를 위한 캐릭터 생성 전문가입니다. 주어진 10가지 설정에 맞는 흥미로운 캐릭터를 생성해주세요."),
                ChatMessage(role: "user", content: prompt)
            ]
        )
        
        return try await callOpenAIAPI(with: request)
    }
    
    // MARK: - 향상된 캐릭터 생성 메서드 (문자열 기반)
    
    func generateEnhancedCharacter(with settings: EnhancedCharacterSettings) async throws -> GeneratedCharacter {
        print("🎭 CharacterGenerationService: Generating enhanced character with flexible settings")
        
        let prompt = createEnhancedPrompt(for: settings)
        let request = CharacterGenerationRequest(
            messages: [
                ChatMessage(role: "system", content: "당신은 창작자를 위한 캐릭터 생성 전문가입니다. 주어진 설정에 맞는 흥미로운 캐릭터를 생성해주세요. '모두' 또는 사용자 정의 입력도 고려해주세요. 반드시 유효한 JSON 형식으로만 응답해주세요."),
                ChatMessage(role: "user", content: prompt)
            ]
        )
        
        return try await callOpenAIAPI(with: request)
    }

    // MARK: - Private Methods
    
    private func createDynamicPrompt(for settings: DynamicCharacterSettings) -> String {
        return """
        다음 10가지 설정에 맞는 캐릭터를 생성해주세요:
        
        장르: \(settings.genre?.name ?? "미정")
        테마: \(settings.theme?.name ?? "미정")
        시대: \(settings.era?.name ?? "미정")
        분위기: \(settings.mood?.name ?? "미정")
        성격: \(settings.personality?.name ?? "미정")
        출신: \(settings.origin?.name ?? "미정")
        약점: \(settings.weakness?.name ?? "미정")
        동기: \(settings.motivation?.name ?? "미정")
        목표: \(settings.goal?.name ?? "미정")
        반전: \(settings.twist?.name ?? "미정")
        
        아래 JSON 형식으로 정확히 응답해주세요:
        {
            "name": "캐릭터 이름",
            "age": "나이 (예: 25세)",
            "appearance": "외모 묘사 (2-3줄)",
            "backstory": "배경 스토리 (3-4줄)",
            "conflict": "내적 갈등이나 문제 (2-3줄)"
        }
        
        한국어로 작성하고, 모든 설정이 자연스럽게 어우러지는 흥미로운 캐릭터를 만들어주세요.
        """
    }
    
    private func createEnhancedPrompt(for settings: EnhancedCharacterSettings) -> String {
        return """
        다음 10가지 설정에 맞는 캐릭터를 생성해주세요:
        
        장르: \(settings.genre)
        테마: \(settings.theme)
        시대: \(settings.era)
        분위기: \(settings.mood)
        성격: \(settings.personality)
        출신: \(settings.origin)
        약점: \(settings.weakness)
        동기: \(settings.motivation)
        목표: \(settings.goal)
        반전: \(settings.twist)
        
        주의사항:
        - "모든 [카테고리]" 형태의 설정은 해당 카테고리의 다양한 요소를 자유롭게 조합해주세요
        - 사용자가 직접 입력한 내용은 창의적으로 해석하여 반영해주세요
        - 모든 설정이 자연스럽게 어우러지도록 해주세요
        
        아래 JSON 형식으로 정확히 응답해주세요:
        {
            "name": "캐릭터 이름",
            "age": "나이 (예: 25세)",
            "appearance": "외모 묘사 (2-3줄)",
            "backstory": "배경 스토리 (3-4줄)",
            "conflict": "내적 갈등이나 문제 (2-3줄)"
        }
        
        한국어로 작성하고, 모든 설정이 자연스럽게 어우러지는 흥미로운 캐릭터를 만들어주세요.
        """
    }
    
    private func callOpenAIAPI(with request: CharacterGenerationRequest) async throws -> GeneratedCharacter {
        return try await callEdgeFunction(with: request)
    }
    
    private func callEdgeFunction(with request: CharacterGenerationRequest) async throws -> GeneratedCharacter {
        print("🌐 Calling Supabase Edge Function for character generation")
        
        let edgeRequest = EdgeFunctionRequest(
            systemMessage: request.messages.first(where: { $0.role == "system" })?.content ?? "",
            userMessage: request.messages.first(where: { $0.role == "user" })?.content ?? "",
            maxTokens: request.maxTokens,
            temperature: request.temperature
        )
        
        print("📤 Edge Function Request: \(String(describing: edgeRequest))")
        
        var urlRequest = URLRequest(url: URL(string: SupabaseConfig.edgeFunctionURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(SupabaseConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 60.0 // 타임아웃 설정
        
        let requestData = try JSONEncoder().encode(edgeRequest)
        urlRequest.httpBody = requestData
        
        print("📤 Request URL: \(SupabaseConfig.edgeFunctionURL)")
        print("📤 Request Size: \(requestData.count) bytes")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CharacterGenerationError.invalidResponse
        }
        
        print("📥 Response Status: \(httpResponse.statusCode)")
        print("📥 Response Size: \(data.count) bytes")
        
        // 응답 내용 로깅 (디버깅용)
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Raw Response: \(responseString)")
        }
        
        guard httpResponse.statusCode == 200 else {
            print("❌ Edge Function Error: Status Code \(httpResponse.statusCode)")
            if let errorData = String(data: data, encoding: .utf8) {
                print("❌ Error Response: \(errorData)")
            }
            throw CharacterGenerationError.apiError(httpResponse.statusCode)
        }
        
        // Edge Function 응답 처리
        do {
            let edgeResponse = try JSONDecoder().decode(EdgeFunctionResponse.self, from: data)
            
            guard edgeResponse.success else {
                let errorMessage = edgeResponse.error ?? "알 수 없는 오류"
                print("❌ Edge Function returned error: \(errorMessage)")
                throw CharacterGenerationError.edgeFunctionError(errorMessage)
            }
            
            print("✅ Character data received: \(edgeResponse.character.name)")
            return GeneratedCharacter(
                name: edgeResponse.character.name,
                age: edgeResponse.character.age,
                appearance: edgeResponse.character.appearance,
                backstory: edgeResponse.character.backstory,
                conflict: edgeResponse.character.conflict
            )
            
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw CharacterGenerationError.invalidJSON
        }
        
    }
    
    private func parseCharacterJSON(_ jsonString: String) throws -> GeneratedCharacter {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw CharacterGenerationError.invalidJSON
        }
        
        let json = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let characterDict = json as? [String: Any] else {
            throw CharacterGenerationError.invalidJSON
        }
        
        guard let name = characterDict["name"] as? String,
              let age = characterDict["age"] as? String,
              let appearance = characterDict["appearance"] as? String,
              let backstory = characterDict["backstory"] as? String,
              let conflict = characterDict["conflict"] as? String else {
            throw CharacterGenerationError.missingFields
        }
        
        return GeneratedCharacter(
            name: name,
            age: age,
            appearance: appearance,
            backstory: backstory,
            conflict: conflict
        )
    }
    

}

// MARK: - 에러 타입
enum CharacterGenerationError: LocalizedError {
    case invalidResponse
    case apiError(Int)
    case noChoices
    case invalidJSON
    case missingFields
    case networkError
    case edgeFunctionError(String)
    case timeout
    case openaiError(String)
    case parsingError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "서버 응답이 올바르지 않습니다"
        case .apiError(let statusCode):
            return "API 오류 (상태 코드: \(statusCode))"
        case .noChoices:
            return "생성된 캐릭터가 없습니다"
        case .invalidJSON:
            return "응답 데이터 형식이 올바르지 않습니다"
        case .missingFields:
            return "필수 캐릭터 정보가 누락되었습니다"
        case .networkError:
            return "네트워크 연결을 확인해주세요"
        case .edgeFunctionError(let message):
            return "서버 오류: \(message)"
        case .timeout:
            return "요청 시간이 초과되었습니다. 다시 시도해주세요"
        case .openaiError(let message):
            return "AI 서비스 오류: \(message)"
        case .parsingError(let message):
            return "응답 처리 중 오류가 발생했습니다: \(message)"
        }
    }
} 

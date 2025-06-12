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
    
    // MARK: - Public Methods
    func generateEnhancedCharacter(with settings: EnhancedCharacterSettings) async throws -> GeneratedCharacter {
        print("🎭 CharacterGenerationService: Sending 10 settings to server")
        
        return try await callEdgeFunctionWithSettings(settings)
    }
    
    // MARK: - Private Methods
    
    /// 동적 프롬프트 생성 (10개 카테고리 기반)
    private func createDynamicPrompt(for settings: DynamicCharacterSettings) -> String {
        return """
        다음 10가지 설정에 맞는 창의적이고 독창적인 캐릭터를 생성해주세요:
        
        📚 장르: \(settings.genre)
        🎨 테마: \(settings.theme)
        🕰️ 시대: \(settings.era)
        💫 분위기: \(settings.mood)
        🎭 성격: \(settings.personality)
        🌟 출신: \(settings.origin)
        💔 약점: \(settings.weakness)
        ❤️ 동기: \(settings.motivation)
        🎯 목표: \(settings.goal)
        ⚡ 반전: \(settings.twist)
        
        다음 JSON 형식으로 응답해주세요:
        {
            "name": "캐릭터 이름",
            "age": "나이 (예: 25세, 불명 등)",
            "appearance": "외모와 특징적인 모습",
            "backstory": "배경 이야기와 과거",
            "conflict": "내적/외적 갈등과 도전"
        }
        """
    }
    
    /// OpenAI API 호출 (레거시 지원)
    private func callOpenAIAPI(with request: CharacterGenerationRequest) async throws -> GeneratedCharacter {
        return try await callEdgeFunction(with: request)
    }
    
    /// 새로운 설정 기반 Edge Function 호출
    private func callEdgeFunctionWithSettings(_ settings: EnhancedCharacterSettings) async throws -> GeneratedCharacter {
        print("🌐 Calling Supabase Edge Function with 10 settings")
        
        let settingsRequest = CharacterGenerationSettingsRequest(
            gender: settings.gender,
            genre: settings.genre,
            theme: settings.theme,
            era: settings.era,
            mood: settings.mood,
            personality: settings.personality,
            origin: settings.origin,
            weakness: settings.weakness,
            motivation: settings.motivation,
            goal: settings.goal,
            twist: settings.twist,
            maxTokens: 500,
            temperature: 0.8
        )
        
        print("📤 Settings Request: \(String(describing: settingsRequest))")
        
        var urlRequest = URLRequest(url: URL(string: SupabaseConfig.edgeFunctionURL)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer \(SupabaseConfig.supabaseAnonKey)", forHTTPHeaderField: "Authorization")
        urlRequest.timeoutInterval = 60.0
        
        let requestData = try JSONEncoder().encode(settingsRequest)
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
            
            // 메타데이터 추출
            let modelUsed = edgeResponse.metadata?.model ?? "gpt-4o-mini"
            let tokensUsed = edgeResponse.metadata?.usage?.totalTokens
            
            // 서버에서 반환받은 설정값들 추출
            let responseSettings = edgeResponse.settings
            
            return GeneratedCharacter(
                name: edgeResponse.character.name,
                age: edgeResponse.character.age,
                appearance: edgeResponse.character.appearance,
                backstory: edgeResponse.character.backstory,
                conflict: edgeResponse.character.conflict,
                modelUsed: modelUsed,
                tokensUsed: tokensUsed,
                gender: responseSettings?.gender,
                genre: responseSettings?.genre,
                theme: responseSettings?.theme,
                era: responseSettings?.era,
                mood: responseSettings?.mood,
                personality: responseSettings?.personality,
                origin: responseSettings?.origin,
                weakness: responseSettings?.weakness,
                motivation: responseSettings?.motivation,
                goal: responseSettings?.goal,
                twist: responseSettings?.twist
            )
            
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw CharacterGenerationError.invalidJSON
        }
    }
    
    /// 레거시 Edge Function 호출
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
        urlRequest.timeoutInterval = 60.0
        
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
            
            // 메타데이터 추출
            let modelUsed = edgeResponse.metadata?.model ?? "gpt-4o-mini"
            let tokensUsed = edgeResponse.metadata?.usage?.totalTokens
            
            return GeneratedCharacter(
                name: edgeResponse.character.name,
                age: edgeResponse.character.age,
                appearance: edgeResponse.character.appearance,
                backstory: edgeResponse.character.backstory,
                conflict: edgeResponse.character.conflict,
                modelUsed: modelUsed,
                tokensUsed: tokensUsed
            )
            
        } catch let decodingError as DecodingError {
            print("❌ JSON Decoding Error: \(decodingError)")
            throw CharacterGenerationError.invalidJSON
        }
    }
    
    /// JSON 파싱 헬퍼 메서드
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

import Foundation
import Supabase

protocol CharacterGenerationServiceProtocol {
    func fetchCategories() async throws -> [CharacterCategory]
    func fetchOptions(for categoryId: Int) async throws -> [CharacterOption]
    func createCharacter(_ request: CharacterCreateRequest) async throws -> Character
}

// MARK: - Edge Function Response Models
private struct EdgeFunctionResponse: Codable {
    let success: Bool
    let character: EdgeCharacter?
    let narrative: String?
    let error: String?
}

private struct EdgeCharacter: Codable {
    let name: String
    let gender: String?
    let age: String?
    let appearance: String?
    let backstory: String?
    let conflict: String?
}



class CharacterGenerationService: CharacterGenerationServiceProtocol {
    static let shared = CharacterGenerationService()
    
    private let client = SupabaseService.shared.client
    
    private init() {}
    
    func fetchCategories() async throws -> [CharacterCategory] {
        do {
            let response: [CharacterCategory] = try await client
                .from("character_category")
                .select()
                .order("id")
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.network(error)
        }
    }
    
    func fetchOptions(for categoryId: Int) async throws -> [CharacterOption] {
        do {
            let response: [CharacterOption] = try await client
                .from("character_option")
                .select()
                .eq("category_id", value: categoryId)
                .order("id")
                .execute()
                .value
            
            return response
        } catch {
            throw AppError.network(error)
        }
    }
    
    func createCharacter(_ request: CharacterCreateRequest) async throws -> Character {
        // Edge Function URL
        guard let url = URL(string: "https://hvttiqbtwhvybozeeqlk.supabase.co/functions/v1/generate-character") else {
            throw AppError.custom("잘못된 서버 주소입니다.")
        }
        
        // URLRequest 생성
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 60.0
        
        // Headers 설정
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Authorization 헤더 추가 (Supabase 세션의 액세스 토큰)
        do {
            let session = try await client.auth.session
            let bearerToken = "Bearer \(session.accessToken)"
            urlRequest.setValue(bearerToken, forHTTPHeaderField: "Authorization")
        } catch {
            throw AppError.authentication(error)
        }
        
        // 추가 헤더
        urlRequest.setValue("ios-app", forHTTPHeaderField: "X-Client-Info")
        urlRequest.setValue(Bundle.main.bundleIdentifier ?? "com.clue.app", forHTTPHeaderField: "X-App-ID")
        
        // Request Body 인코딩 - Edge Function이 기대하는 형식으로 변환
        do {
            // Edge Function이 기대하는 JSON 구조 생성
            let requestBody: [String: Any] = [
                "name": request.name,
                "selected_options": request.selectedOptions, // snake_case로 변환
                "description": "",
                "max_tokens": 500,
                "temperature": 0.8
            ]
            
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
            urlRequest.httpBody = jsonData
            
            // 요청 로그
            print("📤 Sending request to Edge Function:")
            print("   - URL: \(url.absoluteString)")
            print("   - Method: POST")
            print("   - Name: \(request.name)")
            print("   - Options: \(request.selectedOptions.count) categories")
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("   - Request Body: \(jsonString)")
            }
            
        } catch {
            print("❌ Failed to encode request: \(error)")
            throw AppError.custom("요청 데이터 처리 중 오류가 발생했습니다.")
        }
        
        // URLSession으로 요청 실행
        do {
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            // HTTP 응답 상태 확인
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.custom("잘못된 서버 응답입니다.")
            }
            
            print("📥 Edge Function response:")
            print("   - Status Code: \(httpResponse.statusCode)")
            print("   - Content Length: \(data.count) bytes")
            
            // 응답 데이터 로그 (디버깅용)
            if let responseString = String(data: data, encoding: .utf8) {
                print("   - Response Body: \(responseString)")
            }
            
            // 상태 코드별 처리
            switch httpResponse.statusCode {
            case 200...299:
                // 성공 응답 처리
                break
            case 400...499:
                // 클라이언트 오류
                let errorMessage = parseErrorMessage(from: data) ?? "요청 처리 중 오류가 발생했습니다."
                throw AppError.custom(errorMessage)
            case 500...599:
                // 서버 오류
                let errorMessage = parseErrorMessage(from: data) ?? "서버에 일시적인 문제가 발생했습니다."
                throw AppError.custom(errorMessage)
            default:
                throw AppError.custom("예상치 못한 서버 응답입니다. (코드: \(httpResponse.statusCode))")
            }
            
            // 응답 데이터가 비어있는지 확인
            guard !data.isEmpty else {
                throw AppError.custom("서버로부터 응답을 받지 못했습니다.")
            }
            
            // JSON 디코딩 - Edge Function의 실제 응답 구조에 맞게
            let decoder = JSONDecoder()
            
            let edgeResponse: EdgeFunctionResponse
            do {
                edgeResponse = try decoder.decode(EdgeFunctionResponse.self, from: data)
            } catch {
                print("❌ JSON decoding error: \(error)")
                throw AppError.custom("서버 응답 형식이 올바르지 않습니다.")
            }
            
            // 응답 성공 여부 확인
            guard edgeResponse.success else {
                let errorMessage = edgeResponse.error ?? "캐릭터 생성에 실패했습니다."
                print("❌ Edge Function returned error: \(errorMessage)")
                throw AppError.custom(errorMessage)
            }
            
            // 캐릭터 데이터 확인
            guard let edgeCharacter = edgeResponse.character else {
                print("❌ Character data missing in successful response")
                throw AppError.custom("생성된 캐릭터 정보를 받을 수 없습니다.")
            }
            
            // Edge Function의 캐릭터 응답을 앱의 Character 모델로 변환
            let characterDescription = [
                edgeCharacter.gender,
                edgeCharacter.age,
                edgeCharacter.appearance,
                edgeCharacter.backstory,
                edgeCharacter.conflict
            ].compactMap { $0 }.joined(separator: " | ")
            
            // narrative가 있으면 description에 추가
            let finalDescription = if let narrative = edgeResponse.narrative {
                "\(characterDescription)\n\n📖 서사: \(narrative)"
            } else {
                characterDescription
            }
            
            let character = Character(
                id: nil, // 새로 생성된 캐릭터이므로 ID 없음
                userId: nil, // 서버에서 설정
                name: edgeCharacter.name,
                selectedOptions: nil, // Edge Function 응답에는 없음
                gender: edgeCharacter.gender,
                age: edgeCharacter.age,
                appearance: edgeCharacter.appearance,
                backstory: edgeCharacter.backstory,
                conflict: edgeCharacter.conflict,
                narrative: edgeResponse.narrative,
                description: finalDescription, // 호환성을 위해 유지
                imageUrl: nil, // Edge Function에서 이미지는 생성하지 않음
                metadata: nil,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            // 성공 로그
            print("✅ Character created successfully:")
            print("   - Name: \(character.name)")
            print("   - Gender: \(edgeCharacter.gender ?? "N/A")")
            print("   - Age: \(edgeCharacter.age ?? "N/A")")
            print("   - Appearance: \(edgeCharacter.appearance ?? "N/A")")
            print("   - Backstory: \(edgeCharacter.backstory ?? "N/A")")
            print("   - Conflict: \(edgeCharacter.conflict ?? "N/A")")
            if let narrative = edgeResponse.narrative {
                print("   - Narrative: \(narrative)")
            }
            
            return character
            
        } catch let error as AppError {
            throw error
        } catch {
            print("❌ Network error: \(error)")
            throw AppError.network(error)
        }
    }
    
    // MARK: - Private Methods
    
    private func parseErrorMessage(from data: Data) -> String? {
        // 에러 응답에서 메시지 추출 시도
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = jsonObject["message"] as? String {
                return message
            }
            if let error = jsonObject["error"] as? String {
                return error
            }
        }
        
        // 일반 텍스트 응답 시도
        if let errorString = String(data: data, encoding: .utf8), !errorString.isEmpty {
            return errorString
        }
        
        return nil
    }
} 

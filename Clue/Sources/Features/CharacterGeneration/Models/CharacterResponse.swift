//
//  CharacterResponse.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//


// 서버 응답 전체 구조
struct CharacterCreationResponse: Codable {
    let success: Bool
    let character: Character?
    let error: String?
}

//
//  CharacterCreateRequest.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//


// MARK: - Character Creation Request
struct CharacterCreateRequest: Codable {
    let name: String
    let selectedOptions: [String: String]
    let description: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case selectedOptions = "selected_options"
        case description
    }
}

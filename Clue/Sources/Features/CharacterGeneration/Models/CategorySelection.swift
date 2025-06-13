//
//  CategorySelection.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//


// MARK: - Category Selection State
struct CategorySelection {
    let category: CharacterCategory
    let selectedOption: CharacterOption?
    
    var isComplete: Bool {
        selectedOption != nil
    }
} 

//
//  MenuItem.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

// MARK: - MenuItem Model
struct ProfileMenuItem {
    let icon: String
    let title: String
    let titleColor: Color?
    let action: () -> Void
    
    init(icon: String, title: String, titleColor: Color? = nil, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.titleColor = titleColor
        self.action = action
    }
}

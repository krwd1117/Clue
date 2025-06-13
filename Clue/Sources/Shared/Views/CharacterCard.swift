//
//  CharacterCard.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct CharacterCard: View {
    let character: Character
    let onTap: () -> Void
    let onDelete: (() -> Void)?
    
    init(character: Character, onTap: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
        self.character = character
        self.onTap = onTap
        self.onDelete = onDelete
    }
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Background card
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: avatarColors[0].opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                    .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                
                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                avatarColors[0].opacity(0.02),
                                Color.clear,
                                avatarColors[1].opacity(0.01)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                // Content
                VStack(spacing: 0) {
                    // Top section with avatar and name
                    VStack(spacing: 16) {
                        // Character Avatar with enhanced styling
                        ZStack {
                            // Outer glow
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            avatarColors[0].opacity(0.1),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 40
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            // Main avatar
                            RoundedRectangle(cornerRadius: 18)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: avatarColors + [avatarColors[1].opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 68, height: 68)
                                .overlay(
                                    // Subtle inner highlight
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.white.opacity(0.3),
                                                    Color.clear
                                                ]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .shadow(color: avatarColors[0].opacity(0.25), radius: 8, x: 0, y: 4)
                            
                            // Character icon
                            Image(systemName: "person.fill")
                                .font(.system(size: 30, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                        
                        // Character Name with better typography
                        Text(character.name)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.02, green: 0.02, blue: 0.02))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 28)
                    
                    Spacer(minLength: 12)
                    
                    // Bottom info section with badges
                    VStack(spacing: 8) {
                        // Character Summary badges
                        if let gender = character.gender, let age = character.age {
                            HStack(spacing: 8) {
                                // Gender badge
                                HStack(spacing: 4) {
                                    Image(systemName: "person")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(avatarColors[0])
                                    
                                    Text(gender)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(avatarColors[0])
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(avatarColors[0].opacity(0.08))
                                )
                                
                                // Age badge
                                HStack(spacing: 4) {
                                    Image(systemName: "calendar")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(avatarColors[1])
                                    
                                    Text(age)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundColor(avatarColors[1])
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(avatarColors[1].opacity(0.08))
                                )
                            }
                        }
                        
                        // Creation Date with subtle styling
                        if let createdAt = character.createdAt {
                            HStack(spacing: 4) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                                
                                Text(createdAt, formatter: relativeDateFormatter)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(Color(red: 0.6, green: 0.6, blue: 0.6))
                            }
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .frame(height: 180)
        }
        .buttonStyle(EnhancedTossCardButtonStyle())
        .contextMenu {
            if let onDelete = onDelete {
                Button("삭제", systemImage: "trash", role: .destructive) {
                    onDelete()
                }
            }
        }
    }
    
    // Dynamic avatar colors based on character name
    private var avatarColors: [Color] {
        let colorSets: [[Color]] = [
            [Color(red: 0.0, green: 0.4, blue: 1.0), Color(red: 0.2, green: 0.6, blue: 1.0)], // Blue
            [Color(red: 1.0, green: 0.3, blue: 0.5), Color(red: 1.0, green: 0.5, blue: 0.7)], // Pink
            [Color(red: 0.2, green: 0.8, blue: 0.4), Color(red: 0.4, green: 0.9, blue: 0.6)], // Green
            [Color(red: 1.0, green: 0.6, blue: 0.0), Color(red: 1.0, green: 0.7, blue: 0.2)], // Orange
            [Color(red: 0.6, green: 0.3, blue: 1.0), Color(red: 0.7, green: 0.5, blue: 1.0)], // Purple
            [Color(red: 0.0, green: 0.7, blue: 0.9), Color(red: 0.2, green: 0.8, blue: 1.0)]  // Cyan
        ]
        
        let hash = character.name.hash
        let index = abs(hash) % colorSets.count
        return colorSets[index]
    }
    
    private var relativeDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
}

// MARK: - Enhanced Toss Card Button Style
struct EnhancedTossCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - Legacy Toss Card Button Style (for compatibility)
struct TossCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

#Preview {
    LazyVGrid(columns: [
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
        GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
    ], spacing: DesignSystem.Spacing.md) {
        CharacterCard(
            character: Character(
                id: 1,
                userId: "test-user",
                name: "엘리사 드라크리아",
                selectedOptions: nil,
                gender: "여성",
                age: "27세",
                appearance: nil,
                backstory: nil,
                conflict: nil,
                narrative: nil,
                description: nil,
                imageUrl: nil,
                metadata: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            onTap: { print("Character tapped") },
            onDelete: { print("Character deleted") }
        )
        
        CharacterCard(
            character: Character(
                id: 2,
                userId: "test-user",
                name: "마르쿠스 발데론",
                selectedOptions: nil,
                gender: "남성",
                age: "35세",
                appearance: nil,
                backstory: nil,
                conflict: nil,
                narrative: nil,
                description: nil,
                imageUrl: nil,
                metadata: nil,
                createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
                updatedAt: Date()
            ),
            onTap: { print("Character tapped") }
        )
    }
    .padding()
    .background(DesignSystem.Colors.background)
}

//
//  PickerViews.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 장르 선택 뷰
struct GenrePickerView: View {
    @Binding var selectedGenre: CharacterGenre
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(CharacterGenre.allCases, id: \.self) { genre in
                OptionCard(
                    title: genre.displayName,
                    description: genre.description,
                    isSelected: selectedGenre == genre
                ) {
                    selectedGenre = genre
                }
            }
        }
    }
}

// MARK: - 테마 선택 뷰
struct ThemePickerView: View {
    @Binding var selectedTheme: CharacterTheme
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(CharacterTheme.allCases, id: \.self) { theme in
                OptionCard(
                    title: theme.displayName,
                    description: theme.description,
                    isSelected: selectedTheme == theme
                ) {
                    selectedTheme = theme
                }
            }
        }
    }
}

// MARK: - 배경 선택 뷰
struct BackgroundPickerView: View {
    @Binding var selectedBackground: CharacterBackground
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 8) {
            ForEach(CharacterBackground.allCases, id: \.self) { background in
                OptionCard(
                    title: background.displayName,
                    description: background.description,
                    isSelected: selectedBackground == background
                ) {
                    selectedBackground = background
                }
            }
        }
    }
}

// MARK: - 옵션 카드 컴포넌트
struct OptionCard: View {
    let title: String
    let description: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue : Color(.systemGray5))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 개별 Picker 뷰 (iOS 표준 스타일)
struct StandardGenrePickerView: View {
    @Binding var selectedGenre: CharacterGenre
    
    var body: some View {
        Picker("장르 선택", selection: $selectedGenre) {
            ForEach(CharacterGenre.allCases, id: \.self) { genre in
                Text(genre.displayName).tag(genre)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
}

struct StandardThemePickerView: View {
    @Binding var selectedTheme: CharacterTheme
    
    var body: some View {
        Picker("테마 선택", selection: $selectedTheme) {
            ForEach(CharacterTheme.allCases, id: \.self) { theme in
                Text(theme.displayName).tag(theme)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
}

struct StandardBackgroundPickerView: View {
    @Binding var selectedBackground: CharacterBackground
    
    var body: some View {
        Picker("배경 선택", selection: $selectedBackground) {
            ForEach(CharacterBackground.allCases, id: \.self) { background in
                Text(background.displayName).tag(background)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
}

// MARK: - 미리보기
#Preview("Genre Picker") {
    GenrePickerView(selectedGenre: .constant(.fantasy))
        .padding()
}

#Preview("Theme Picker") {
    ThemePickerView(selectedTheme: .constant(.redemption))
        .padding()
}

#Preview("Background Picker") {
    BackgroundPickerView(selectedBackground: .constant(.medievalKingdom))
        .padding()
} 
//
//  CharacterDetailView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    let onCharacterDeleted: (() -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    init(character: Character, onCharacterDeleted: (() -> Void)? = nil) {
        self.character = character
        self.onCharacterDeleted = onCharacterDeleted
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 헤더 영역
                headerSection
                
                // 메인 콘텐츠
                VStack(spacing: 24) {
                    // 캐릭터 기본 정보
                    characterBasicInfo
                    
                    // 상세 정보 카드들
                    detailCards
                }
                .padding(.horizontal, 20)
                .padding(.top, 32)
                .padding(.bottom, 40)
            }
        }
        .background(Color.white)
        .ignoresSafeArea(.all, edges: .top)
        .overlay(alignment: .topTrailing) {
            // 네비게이션 버튼들
            navigationButtons
        }
        .alert("캐릭터 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                Task { await deleteCharacter() }
            }
        } message: {
            Text("'\(character.name)' 캐릭터를 삭제하시겠습니까?")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 0) {
            // 상단 여백 (Safe Area)
            Rectangle()
                .fill(Color.clear)
                .frame(height: 50)
            
            // 캐릭터 아바타와 이름
            VStack(spacing: 20) {
                // 아바타
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [themeColor.opacity(0.1), themeColor.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Text(String(character.name.prefix(1)))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(themeColor)
                }
                
                // 캐릭터 이름
                Text(character.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.black)
                
                // 기본 정보 태그들
                HStack(spacing: 12) {
                    if let gender = character.gender {
                        infoTag(text: gender, icon: "person.fill")
                    }
                    
                    if let age = character.age {
                        infoTag(text: age, icon: "calendar")
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [Color.white, Color(red: 0.98, green: 0.98, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Character Basic Info
    private var characterBasicInfo: some View {
        VStack(spacing: 16) {
            HStack {
                Text("기본 정보")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(spacing: 12) {
                if let appearance = character.appearance, !appearance.isEmpty {
                    infoRow(title: "외모", content: appearance, icon: "eye")
                }
                
                if let backstory = character.backstory, !backstory.isEmpty {
                    infoRow(title: "배경", content: backstory, icon: "book.closed")
                }
                
                if let conflict = character.conflict, !conflict.isEmpty {
                    infoRow(title: "갈등", content: conflict, icon: "exclamationmark.triangle")
                }
            }
        }
    }
    
    // MARK: - Detail Cards
    private var detailCards: some View {
        VStack(spacing: 20) {
            // 서사 카드
            if let narrative = character.narrative, !narrative.isEmpty {
                narrativeCard(narrative)
            }
            
            // 선택된 옵션 카드
            if let selectedOptions = character.selectedOptions, !selectedOptions.isEmpty {
                selectedOptionsCard(selectedOptions)
            }
            
            // 생성 정보 카드
            if let createdAt = character.createdAt {
                creationInfoCard(createdAt)
            }
        }
    }
    
    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 12) {
            // 닫기 버튼
            Button(action: { dismiss() }) {
                Circle()
                    .fill(Color.black.opacity(0.05))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                    )
            }
            
            // 메뉴 버튼
            Menu {
                Button("삭제", systemImage: "trash", role: .destructive) {
                    showingDeleteAlert = true
                }
            } label: {
                Circle()
                    .fill(Color.black.opacity(0.05))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                    )
            }
        }
        .padding(.top, 50)
        .padding(.trailing, 20)
    }
    
    // MARK: - Helper Views
    private func infoTag(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeColor)
            
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(themeColor.opacity(0.08))
        )
    }
    
    private func infoRow(title: String, content: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // 아이콘
            Circle()
                .fill(themeColor.opacity(0.1))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeColor)
                )
            
            // 내용
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.black)
                
                Text(content)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.black.opacity(0.7))
                    .lineSpacing(2)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func narrativeCard(_ narrative: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("캐릭터 서사")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color.orange.opacity(0.1))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "quote.bubble")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.orange)
                        )
                    
                    Text("스토리")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                
                Text(narrative)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.black.opacity(0.8))
                    .lineSpacing(4)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.99, green: 0.99, blue: 1.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }
    
    private func selectedOptionsCard(_ selectedOptions: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("선택된 옵션")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            // 2열 그리드로 변경
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                ForEach(Array(selectedOptions.keys.sorted()), id: \.self) { key in
                    if let value = selectedOptions[key], !value.isEmpty {
                        optionChip(
                            category: getCategoryName(for: key),
                            value: value,
                            categoryId: key
                        )
                    }
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.99, green: 0.99, blue: 1.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }
    
    private func optionChip(category: String, value: String, categoryId: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // 카테고리 제목
            Text(category)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(getCategoryColor(for: categoryId))
                .textCase(.uppercase)
            
            // 선택된 값
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .lineSpacing(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(getCategoryColor(for: categoryId).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(getCategoryColor(for: categoryId).opacity(0.15), lineWidth: 1)
                )
        )
    }
    
    private func creationInfoCard(_ createdAt: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("생성 정보")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 16) {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.green)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("생성일")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                    
                    Text(createdAt, formatter: dateFormatter)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.99, green: 0.99, blue: 1.0))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Helper Methods
    private func deleteCharacter() async {
        guard let characterId = character.id else { return }
        
        do {
            try await CharacterLibraryService.shared.deleteCharacter(id: characterId)
            dismiss()
            onCharacterDeleted?()
        } catch {
            print("❌ 캐릭터 삭제 실패: \(error)")
        }
    }
    
    private var themeColor: Color {
        let colors: [Color] = [
            Color(red: 0.0, green: 0.48, blue: 1.0),    // Blue
            Color(red: 0.2, green: 0.78, blue: 0.35),   // Green
            Color(red: 1.0, green: 0.58, blue: 0.0),    // Orange
            Color(red: 0.55, green: 0.27, blue: 0.95),  // Purple
            Color(red: 1.0, green: 0.23, blue: 0.19),   // Red
            Color(red: 0.0, green: 0.78, blue: 0.75)    // Teal
        ]
        let hash = character.name.hash
        let index = abs(hash) % colors.count
        return colors[index]
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
    
    private func getCategoryName(for categoryId: String) -> String {
        let categoryNames: [String: String] = [
            "1": "세계관·장르",
            "2": "역할·위치", 
            "3": "이름·신상",
            "4": "출신·배경",
            "5": "외모 묘사",
            "6": "성격·심리",
            "7": "동기·목표",
            "8": "갈등·약점",
            "9": "주요 관계",
            "10": "특별 능력·장비",
            "11": "대사·말투 톤",
            "12": "추가 힌트"
        ]
        
        return categoryNames[categoryId] ?? "카테고리 \(categoryId)"
    }
    
    private func getCategoryColor(for categoryId: String) -> Color {
        let colors: [Color] = [
            Color(red: 0.0, green: 0.48, blue: 1.0),    // Blue
            Color(red: 0.2, green: 0.78, blue: 0.35),   // Green  
            Color(red: 1.0, green: 0.58, blue: 0.0),    // Orange
            Color(red: 0.55, green: 0.27, blue: 0.95),  // Purple
            Color(red: 1.0, green: 0.23, blue: 0.19),   // Red
            Color(red: 0.0, green: 0.78, blue: 0.75),   // Teal
            Color(red: 1.0, green: 0.41, blue: 0.71),   // Pink
            Color(red: 0.35, green: 0.34, blue: 0.84),  // Indigo
            Color(red: 0.96, green: 0.76, blue: 0.05),  // Yellow
            Color(red: 0.63, green: 0.51, blue: 0.41),  // Brown
            Color(red: 0.56, green: 0.56, blue: 0.58),  // Gray
            Color(red: 0.30, green: 0.69, blue: 0.31)   // Light Green
        ]
        
        if let id = Int(categoryId), id >= 1 && id <= 12 {
            return colors[id - 1]
        }
        return themeColor
    }
}

#Preview {
    CharacterDetailView(
        character: Character(name: "테스트 캐릭터"),
        onCharacterDeleted: {}
    )
}

//
//  CharacterDetailView.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

struct CharacterDetailView: View {
    let character: Character
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(red: 0.98, green: 0.98, blue: 0.99)
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        // Hero Header Section
                        heroHeaderSection
                        
                        // Content sections
                        VStack(spacing: 24) {
                            // Character Info Cards
                            characterInfoSection
                            
                            // Narrative Section
                            if let narrative = character.narrative, !narrative.isEmpty {
                                narrativeSection(narrative)
                            }
                            
                            // Selected Options Section
                            if let selectedOptions = character.selectedOptions, !selectedOptions.isEmpty {
                                selectedOptionsSection(selectedOptions)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 40) // Space for floating card
                        .padding(.bottom, 40)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            .overlay(
                // Custom navigation bar
                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            }
                        }
                        
                        Spacer()
                        
                        Menu {
                            Button("편집", systemImage: "pencil") {
                                // TODO: 편집 기능
                            }
                            
                            Button("삭제", systemImage: "trash", role: .destructive) {
                                showingDeleteAlert = true
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: 36, height: 36)
                                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            )
        }
        .alert("캐릭터 삭제", isPresented: $showingDeleteAlert) {
            Button("취소", role: .cancel) { }
            
            Button("삭제", role: .destructive) {
                Task {
                    await deleteCharacter()
                }
            }
        } message: {
            Text("'\(character.name)' 캐릭터를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.")
        }
    }
    
    // MARK: - Delete Character
    private func deleteCharacter() async {
        guard let characterId = character.id else { return }
        
        do {
            try await CharacterLibraryService.shared.deleteCharacter(id: characterId)
            dismiss()
        } catch {
            print("❌ 캐릭터 삭제 실패: \(error)")
            // TODO: 에러 처리
        }
    }
    
    // MARK: - Hero Header Section
    private var heroHeaderSection: some View {
        ZStack(alignment: .bottom) {
            // Background gradient with dynamic colors
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: avatarColors + [avatarColors[1].opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 280)
                .overlay(
                    // Subtle pattern overlay
                    Rectangle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear
                                ]),
                                center: .topTrailing,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                )
            
            // Content
            VStack(spacing: 20) {
                Spacer()
                
                // Character Avatar
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        )
                        .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "person.fill")
                        .font(.system(size: 52, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                // Character Name and basic info
                VStack(spacing: 8) {
                    Text(character.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Quick info badges
                    HStack(spacing: 12) {
                        if let gender = character.gender {
                            infoBadge(text: gender, icon: "person")
                        }
                        
                        if let age = character.age {
                            infoBadge(text: age, icon: "calendar")
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            
            // Floating info card
            if let createdAt = character.createdAt {
                HStack {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(avatarColors[0])
                    
                    Text("생성일")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    
                    Spacer()
                    
                    Text(createdAt, formatter: dateFormatter)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
                .padding(.horizontal, 20)
                .offset(y: 20)
            }
        }
    }
    
    // Info badge helper
    private func infoBadge(text: String, icon: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white)
            
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
        )
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
    
    // MARK: - Character Info Section
    private var characterInfoSection: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                Text("캐릭터 정보")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Info cards
            VStack(spacing: 12) {
                if let appearance = character.appearance, !appearance.isEmpty {
                    characterInfoCard(title: "외모", content: appearance, icon: "eye", color: avatarColors[0])
                }
                
                if let backstory = character.backstory, !backstory.isEmpty {
                    characterInfoCard(title: "배경", content: backstory, icon: "book", color: Color(red: 0.6, green: 0.3, blue: 1.0))
                }
                
                if let conflict = character.conflict, !conflict.isEmpty {
                    characterInfoCard(title: "갈등", content: conflict, icon: "bolt", color: Color(red: 1.0, green: 0.3, blue: 0.5))
                }
            }
        }
    }
    
    // MARK: - Character Info Card
    private func characterInfoCard(title: String, content: String, icon: String, color: Color) -> some View {
        HStack(alignment: .top, spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.1))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                
                Text(content)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.25))
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(color.opacity(0.08), lineWidth: 1)
        )
    }
    
    // MARK: - Narrative Section
    private func narrativeSection(_ narrative: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                Text("캐릭터 서사")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Narrative card
            VStack(alignment: .leading, spacing: 16) {
                // Decorative header
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 1.0, green: 0.6, blue: 0.0),
                                        Color(red: 1.0, green: 0.7, blue: 0.2)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "book.pages")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("스토리")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                        
                        Text("캐릭터의 배경 이야기")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    
                    Spacer()
                }
                
                // Quote-style narrative
                VStack(alignment: .leading, spacing: 12) {
                    // Opening quote mark
                    //                    HStack {
                    //                        Text(""")
                    //                            .font(.system(size: 32, weight: .bold))
                    //                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.3))
                    //                        
                    //                        Spacer()
                    //                    }
                    
                    Text(narrative)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .lineSpacing(6)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                    
                    // Closing quote mark
                    //                    HStack {
                    //                        Spacer()
                    //                        
                    //                        Text(""")
                    //                            .font(.system(size: 32, weight: .bold))
                    //                            .foregroundColor(Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.3))
                    //                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white,
                                Color(red: 1.0, green: 0.98, blue: 0.95)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 1.0, green: 0.6, blue: 0.0).opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Selected Options Section
    private func selectedOptionsSection(_ selectedOptions: [String: String]) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                Text("생성 옵션")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                
                Spacer()
            }
            .padding(.horizontal, 4)
            
            // Options card
            VStack(alignment: .leading, spacing: 20) {
                // Header with icon
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.2, green: 0.8, blue: 0.4),
                                        Color(red: 0.4, green: 0.9, blue: 0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("선택된 옵션")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.05))
                        
                        Text("캐릭터 생성 시 선택한 설정")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5))
                    }
                    
                    Spacer()
                }
                
                // Options grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    ForEach(Array(selectedOptions.keys.sorted()), id: \.self) { key in
                        if let value = selectedOptions[key], !value.isEmpty {
                            optionChip(category: getCategoryName(for: key), value: value)
                        }
                    }
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 4)
                    .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.08), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Option Chip
    private func optionChip(category: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(category)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                .textCase(.uppercase)
                .tracking(0.5)
            
            Text(value)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(red: 0.2, green: 0.8, blue: 0.4).opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Helper Methods
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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }
}

#Preview {
    CharacterDetailView(
        character: Character(
            id: 1,
            userId: "test-user",
            name: "엘리사 드라크리아",
            selectedOptions: [
                "1": "다크 판타지",
                "2": "암살자",
                "4": "왕실 기사 가문"
            ],
            gender: "여성",
            age: "27세",
            appearance: "짙은 은발과 차가운 회색 눈동자, 검은 망토를 두른 그림자 같은 자태",
            backstory: "왕실 기사였던 아버지를 잃고 떠돌이 암살자로 자라났다",
            conflict: "복수심과 정의 사이에서 갈등한다",
            narrative: "북부의 얼음 마을, 창백한 달빛 아래 은발이 부드럽게 빛난다. 복수와 정의 사이에서 흔들리는 마음을 다잡으며, 그녀는 운명의 길을 향해 한 걸음씩 나아간다.",
            description: nil,
            imageUrl: nil,
            metadata: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
    )
} 

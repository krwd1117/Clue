//
//  SavedCharactersView.swift
//  Clue
//
//  Created by Assistant on 12/25/24.
//

import SwiftUI

// MARK: - 저장된 캐릭터 목록 뷰
struct SavedCharactersView: View {
    @StateObject private var storageService = CharacterStorageService.shared
    @StateObject private var authService = AuthService.shared
    @EnvironmentObject var navigationRouter: NavigationRouter
    
    @State private var showingDeleteConfirm = false
    @State private var characterToDelete: GeneratedCharacter?
    @State private var searchText = ""
    @State private var selectedSortOption: SortOption = .newest
    @State private var showingSortOptions = false
    @State private var isGridView = true
    
    // 모달 관련 상태
    @State private var selectedCharacter: GeneratedCharacter?
    
    // 애니메이션 상태
    @State private var animationOffset: CGFloat = 30
    @State private var animationOpacity: Double = 0
    
    enum SortOption: String, CaseIterable {
        case newest = "최신순"
        case oldest = "오래된순"
        case name = "이름순"
        
        var systemImage: String {
            switch self {
            case .newest: return "clock.arrow.2.circlepath"
            case .oldest: return "clock"
            case .name: return "textformat.abc"
            }
        }
    }
    
    var filteredAndSortedCharacters: [GeneratedCharacter] {
        let filtered = searchText.isEmpty ? storageService.savedCharacters :
            storageService.savedCharacters.filter { character in
                character.name.localizedCaseInsensitiveContains(searchText) ||
                character.appearance.localizedCaseInsensitiveContains(searchText) ||
                character.backstory.localizedCaseInsensitiveContains(searchText) ||
                character.conflict.localizedCaseInsensitiveContains(searchText)
            }
        
        return filtered.sorted { char1, char2 in
            switch selectedSortOption {
            case .newest:
                return char1.createdAt > char2.createdAt
            case .oldest:
                return char1.createdAt < char2.createdAt
            case .name:
                return char1.name < char2.name
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // 배경 그라디언트
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                Group {
                    if !authService.isAuthenticated {
                        loginRequiredView
                    } else if storageService.isLoading {
                        loadingView
                    } else if storageService.savedCharacters.isEmpty {
                        emptyStateView
                    } else {
                        mainContentView
                    }
                }
                .offset(y: animationOffset)
                .opacity(animationOpacity)
                .onAppear {
                    withAnimation(.easeOut(duration: 0.6)) {
                        animationOffset = 0
                        animationOpacity = 1
                    }
                }
            }
            .navigationTitle("내 캐릭터")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if authService.isAuthenticated && !storageService.savedCharacters.isEmpty {
                        // 뷰 타입 전환 버튼
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isGridView.toggle()
                            }
                        } label: {
                            Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        // 정렬 버튼
                        Button {
                            showingSortOptions = true
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    
                    // 캐릭터 생성 버튼
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            navigationRouter.push(.characterGeneration)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.blue)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "캐릭터 검색...")
            .onAppear {
                if authService.isAuthenticated {
                    Task {
                        await loadCharacters()
                    }
                }
            }
            .refreshable {
                await loadCharacters()
            }
        }
        .confirmationDialog("정렬 방식", isPresented: $showingSortOptions) {
            ForEach(SortOption.allCases, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedSortOption = option
                    }
                } label: {
                    Label(option.rawValue, systemImage: option.systemImage)
                }
            }
        }
        .alert("캐릭터 삭제", isPresented: $showingDeleteConfirm) {
            Button("취소", role: .cancel) { }
            Button("삭제", role: .destructive) {
                if let character = characterToDelete {
                    deleteCharacter(character)
                }
            }
        } message: {
            Text("'\(characterToDelete?.name ?? "")'를 삭제하시겠습니까?")
        }
        .alert("오류", isPresented: .constant(storageService.error != nil)) {
            Button("확인") {
                storageService.clearError()
            }
        } message: {
            if let error = storageService.error {
                Text(error)
            }
        }
        .sheet(item: $selectedCharacter) { character in
            CharacterDetailModalView(character: character) {
                selectedCharacter = nil
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var loginRequiredView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.crop.circle.dashed")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(.blue)
            }
            
            VStack(spacing: 12) {
                Text("로그인이 필요합니다")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("저장된 캐릭터를 보려면\n로그인해주세요")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Button("로그인하기") {
                // TODO: 실제 로그인 화면 연결
                navigationRouter.popToRoot()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
            
            Text("캐릭터를 불러오는 중...")
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(.blue)
            }
            
            VStack(spacing: 12) {
                Text("아직 캐릭터가 없어요")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("첫 번째 캐릭터를 생성하고\n나만의 컬렉션을 시작해보세요!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    navigationRouter.push(.characterGeneration)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("캐릭터 생성하기")
                }
                .font(.system(size: 16, weight: .semibold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                // 통계 정보 헤더
                if !filteredAndSortedCharacters.isEmpty {
                    statsHeaderView
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                
                // 캐릭터 목록
                if isGridView {
                    gridContentView
                } else {
                    listContentView
                }
            }
            .padding(.top, 16)
            .padding(.bottom, 100) // 탭바 여백
        }
    }
    
    @ViewBuilder
    private var statsHeaderView: some View {
        HStack(spacing: 16) {
            StatCard(
                title: "총 캐릭터",
                value: "\(filteredAndSortedCharacters.count)",
                icon: "person.3.fill",
                color: .blue
            )
            
            StatCard(
                title: "이번 달",
                value: "\(charactersThisMonth)",
                icon: "calendar",
                color: .orange
            )
        }
    }
    
    @ViewBuilder
    private var gridContentView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 16) {
            ForEach(filteredAndSortedCharacters.indices, id: \.self) { index in
                let character = filteredAndSortedCharacters[index]
                ModernCharacterGridCard(
                    character: character,
                    onTap: { showCharacterDetail(character) },
                    onDelete: {
                        characterToDelete = character
                        showingDeleteConfirm = true
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale.combined(with: .opacity),
                    removal: .scale.combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.05), value: filteredAndSortedCharacters.count)
            }
        }
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var listContentView: some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredAndSortedCharacters.indices, id: \.self) { index in
                let character = filteredAndSortedCharacters[index]
                ModernCharacterListCard(
                    character: character,
                    onTap: { showCharacterDetail(character) },
                    onDelete: {
                        characterToDelete = character
                        showingDeleteConfirm = true
                    }
                )
                .transition(.asymmetric(
                    insertion: .move(edge: .leading).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .animation(.spring(response: 0.4, dampingFraction: 0.8).delay(Double(index) * 0.03), value: filteredAndSortedCharacters.count)
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Computed Properties
    
    private var totalTokensUsed: Int {
        filteredAndSortedCharacters.compactMap { $0.tokensUsed }.reduce(0, +)
    }
    
    private var charactersThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return filteredAndSortedCharacters.filter { character in
            calendar.isDate(character.createdAt, equalTo: now, toGranularity: .month)
        }.count
    }
    
    // MARK: - Actions
    
    private func loadCharacters() async {
        do {
            try await storageService.loadUserCharacters()
        } catch {
            print("❌ Failed to load characters: \(error)")
        }
    }
    
    private func showCharacterDetail(_ character: GeneratedCharacter) {
        selectedCharacter = character
    }
    
    private func deleteCharacter(_ character: GeneratedCharacter) {
        Task {
            do {
                try await storageService.deleteCharacter(character)
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        // 캐릭터 삭제 완료 - UI 업데이트는 storageService가 처리
                    }
                }
            } catch {
                print("❌ Failed to delete character: \(error)")
            }
        }
    }
}

// MARK: - 현대적인 그리드 카드 컴포넌트
struct ModernCharacterGridCard: View {
    let character: GeneratedCharacter
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // 캐릭터 아바타
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                    
                    Text(String(character.name.prefix(2)))
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                }
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                // 캐릭터 정보
                VStack(spacing: 8) {
                    Text(character.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(character.age)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                    
                    Text(character.appearance)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.blue)
                        .lineLimit(1)
                        .padding(.horizontal, 8)
                }
                
                Spacer()
                
                // 하단 메타 정보
                HStack {
                    Text(formattedDate(character.createdAt))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Menu {
                        Button(role: .destructive) {
                            onDelete()
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Circle().fill(Color(.systemGray6)))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(20)
            .frame(height: 240)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(isPressed ? 0.15 : 0.08), radius: isPressed ? 4 : 12, x: 0, y: isPressed ? 2 : 6)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

// MARK: - 현대적인 리스트 카드 컴포넌트
struct ModernCharacterListCard: View {
    let character: GeneratedCharacter
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 캐릭터 아바타
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.8), .purple.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Text(String(character.name.prefix(2)))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                }
                .shadow(color: .blue.opacity(0.3), radius: 6, x: 0, y: 3)
                
                // 캐릭터 정보
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(character.name)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(character.age)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue.opacity(0.8))
                            .clipShape(Capsule())
                    }
                    
                    Text(character.appearance)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                    
                    Text(character.backstory)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack {
                        Text(formattedDate(character.createdAt))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        if let tokensUsed = character.tokensUsed {
                            HStack(spacing: 4) {
                                Image(systemName: "cpu")
                                    .font(.system(size: 10))
                                Text("\(tokensUsed)")
                                    .font(.system(size: 11, weight: .medium))
                            }
                            .foregroundColor(.gray)
                        }
                        
                        Menu {
                            Button(role: .destructive) {
                                onDelete()
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(isPressed ? 0.12 : 0.06), radius: isPressed ? 3 : 8, x: 0, y: isPressed ? 1 : 4)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0) { } onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}



// MARK: - 미리보기
#Preview {
    SavedCharactersView()
        .environmentObject(NavigationRouter())
} 

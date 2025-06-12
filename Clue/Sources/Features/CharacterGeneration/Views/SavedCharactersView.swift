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
    @State private var animationOffset: CGFloat = 20
    @State private var animationOpacity: Double = 0
    @State private var isAnimating = false
    
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
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // 헤더
                    VStack(spacing: 20) {
                        // 제목 섹션
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("내 캐릭터")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                                
                                Text("\(storageService.savedCharacters.count)개")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // 컨트롤 버튼들
                            HStack(spacing: 12) {
                                // 뷰 타입 전환
                                Button {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        isGridView.toggle()
                                    }
                                } label: {
                                    Image(systemName: isGridView ? "list.bullet" : "square.grid.2x2")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(width: 40, height: 40)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                
                                // 정렬 버튼
                                Button {
                                    showingSortOptions = true
                                } label: {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.blue)
                                        .frame(width: 40, height: 40)
                                        .background(Color.blue.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                
                                // 캐릭터 생성 버튼
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                        navigationRouter.push(.characterGeneration)
                                    }
                                }) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 40, height: 40)
                                        .background(Color.blue)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                }
                            }
                        }
                        
                        // 검색 바
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            TextField("캐릭터 검색...", text: $searchText)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                            
                            if !searchText.isEmpty {
                                Button {
                                    searchText = ""
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // 메인 콘텐츠
                    Group {
                        if storageService.isLoading {
                            loadingView
                        } else if storageService.savedCharacters.isEmpty {
                            emptyStateView
                        } else {
                            mainContentView
                        }
                    }
                    .offset(y: animationOffset)
                    .opacity(animationOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animationOffset = 0
                animationOpacity = 1
                isAnimating = true
            }
            
            if authService.isAuthenticated {
                Task {
                    await loadCharacters()
                }
            }
        }
        .refreshable {
            await loadCharacters()
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
            Text("'\(characterToDelete?.name ?? "")'를 정말 삭제하시겠습니까?")
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
    
    @ViewBuilder
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.blue)
            
            Text("캐릭터 불러오는 중...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 12) {
                Text("저장된 캐릭터가 없습니다")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Text("첫 번째 캐릭터를 생성해보세요")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    navigationRouter.push(.characterGeneration)
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("캐릭터 생성하기")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private var mainContentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 20) {
                if isGridView {
                    gridView
                } else {
                    listView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
    
    @ViewBuilder
    private var gridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(Array(filteredAndSortedCharacters.enumerated()), id: \.element.id) { index, character in
                CharacterCard(
                    character: character,
                    delay: Double(index) * 0.05
                ) {
                    selectedCharacter = character
                } onDelete: {
                    characterToDelete = character
                    showingDeleteConfirm = true
                }
            }
        }
    }
    
    @ViewBuilder
    private var listView: some View {
        LazyVStack(spacing: 12) {
            ForEach(Array(filteredAndSortedCharacters.enumerated()), id: \.element.id) { index, character in
                CharacterListItem(
                    character: character,
                    delay: Double(index) * 0.03
                ) {
                    selectedCharacter = character
                } onDelete: {
                    characterToDelete = character
                    showingDeleteConfirm = true
                }
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadCharacters() async {
        do {
            try await storageService.loadUserCharacters()
        } catch {
            print("❌ Failed to load characters: \(error)")
        }
    }
    
    private func deleteCharacter(_ character: GeneratedCharacter) {
        Task {
            do {
                try await storageService.deleteCharacter(character)
            } catch {
                print("❌ Failed to delete character: \(error)")
            }
        }
    }
}

// MARK: - 캐릭터 카드 (그리드용)
struct CharacterCard: View {
    let character: GeneratedCharacter
    let delay: Double
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var isVisible = false
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                // 캐릭터 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 80)
                    
                    Image(systemName: "person.crop.artframe")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.blue)
                }
                
                // 캐릭터 정보
                VStack(spacing: 4) {
                    Text(character.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(character.appearance.prefix(40))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text(character.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .scaleEffect(isVisible ? 1 : 0.9)
        .opacity(isVisible ? 1 : 0)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - 캐릭터 리스트 아이템 (리스트용)
struct CharacterListItem: View {
    let character: GeneratedCharacter
    let delay: Double
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var isVisible = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 캐릭터 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "person.crop.artframe")
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.blue)
                }
                
                // 캐릭터 정보
                VStack(alignment: .leading, spacing: 2) {
                    Text(character.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(character.appearance)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                    
                    Text(character.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                // 화살표
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(12)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .scaleEffect(isVisible ? 1 : 0.95)
        .opacity(isVisible ? 1 : 0)
        .contextMenu {
            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("삭제", systemImage: "trash")
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

#Preview {
    SavedCharactersView()
        .environmentObject(NavigationRouter())
} 

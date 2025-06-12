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
    @State private var isAnimating = false
    @State private var galleryVisible = false
    
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
                // 창작 테마 배경
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.08, green: 0.05, blue: 0.25), // 깊은 네이비
                        Color(red: 0.18, green: 0.1, blue: 0.35),  // 중간 보라
                        Color(red: 0.28, green: 0.2, blue: 0.45),  // 밝은 보라
                        Color(red: 0.38, green: 0.3, blue: 0.55)   // 연한 보라
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                // 떠다니는 창작 요소들
                ForEach(0..<8, id: \.self) { index in
                    FloatingGalleryElement(index: index)
                        .opacity(0.15)
                }
                
                VStack(spacing: 0) {
                    // 커스텀 헤더
                    CreativeGalleryHeader(
                        searchText: $searchText,
                        isGridView: $isGridView,
                        selectedSortOption: $selectedSortOption,
                        showingSortOptions: $showingSortOptions,
                        charactersCount: storageService.savedCharacters.count,
                        onCreateCharacter: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                navigationRouter.push(.characterGeneration)
                            }
                        }
                    )
                    
                    // 메인 콘텐츠
                    Group {
                        if storageService.isLoading {
                            creativeLoadingView
                        } else if storageService.savedCharacters.isEmpty {
                            creativeEmptyStateView
                        } else {
                            creativeMainContentView
                        }
                    }
                    .offset(y: animationOffset)
                    .opacity(animationOpacity)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: galleryVisible)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                animationOffset = 0
                animationOpacity = 1
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                galleryVisible = true
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
    private var creativeLoadingView: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.2), lineWidth: 4)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        AngularGradient(
                            colors: [.cyan, .purple, .pink, .cyan],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isAnimating)
            }
            
            VStack(spacing: 8) {
                Text("캐릭터 갤러리 로딩 중...")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                
                Text("✨ 창작의 세계가 펼쳐집니다 ✨")
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(.cyan.opacity(0.8))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var creativeEmptyStateView: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.3),
                                Color.purple.opacity(0.2),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 60, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan.opacity(0.9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 10)
            }
            
            VStack(spacing: 16) {
                Text("캐릭터 갤러리가 비어있습니다")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("첫 번째 캐릭터를 창조하여\n당신만의 창작 세계를 시작해보세요")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                
                Text("🎭 • ✨ • 🌟")
                    .font(.system(size: 18))
                    .opacity(0.7)
                    .padding(.top, 8)
            }
            
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    navigationRouter.push(.characterGeneration)
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .font(.system(size: 18, weight: .medium))
                    
                    Text("첫 캐릭터 창조하기")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [.cyan.opacity(0.8), .purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: .cyan.opacity(0.4), radius: 10, x: 0, y: 5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 40)
    }
    
    @ViewBuilder
    private var creativeMainContentView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 20) {
                if isGridView {
                    creativeGridView
                } else {
                    creativeListView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
        .opacity(galleryVisible ? 1 : 0)
        .offset(y: galleryVisible ? 0 : 20)
    }
    
    @ViewBuilder
    private var creativeGridView: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ], spacing: 20) {
            ForEach(Array(filteredAndSortedCharacters.enumerated()), id: \.element.id) { index, character in
                CreativeCharacterCard(
                    character: character,
                    delay: Double(index) * 0.1
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
    private var creativeListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(filteredAndSortedCharacters.enumerated()), id: \.element.id) { index, character in
                CreativeCharacterListItem(
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

// MARK: - 떠다니는 갤러리 요소
struct FloatingGalleryElement: View {
    let index: Int
    @State private var isMoving = false
    @State private var rotation: Double = 0
    
    private let symbols = ["photo.on.rectangle", "rectangle.stack", "person.crop.rectangle", "frame", "viewfinder", "camera.viewfinder"]
    private let colors: [Color] = [.cyan, .purple, .pink, .orange, .yellow, .mint]
    
    var body: some View {
        Image(systemName: symbols[index % symbols.count])
            .font(.system(size: CGFloat.random(in: 20...35), weight: .light))
            .foregroundColor(colors[index % colors.count])
            .opacity(0.6)
            .offset(
                x: isMoving ? CGFloat.random(in: -120...120) : CGFloat.random(in: -60...60),
                y: isMoving ? CGFloat.random(in: -250...250) : CGFloat.random(in: -125...125)
            )
            .rotationEffect(.degrees(rotation))
            .animation(
                .easeInOut(duration: Double.random(in: 5...10))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.3),
                value: isMoving
            )
            .animation(
                .linear(duration: Double.random(in: 15...25))
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.2),
                value: rotation
            )
            .onAppear {
                isMoving = true
                rotation = 360
            }
    }
}

// MARK: - 창작 갤러리 헤더
struct CreativeGalleryHeader: View {
    @Binding var searchText: String
    @Binding var isGridView: Bool
    @Binding var selectedSortOption: SavedCharactersView.SortOption
    @Binding var showingSortOptions: Bool
    let charactersCount: Int
    let onCreateCharacter: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 제목 섹션
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("캐릭터 갤러리")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("\(charactersCount)개의 창작품")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.cyan.opacity(0.8))
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
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // 정렬 버튼
                    Button {
                        showingSortOptions = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        Circle()
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                    
                    // 캐릭터 생성 버튼
                    Button(action: onCreateCharacter) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.cyan.opacity(0.8), .purple.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.4), radius: 8)
                    }
                }
            }
            
            // 검색 바
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                
                TextField("캐릭터 검색...", text: $searchText)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .accentColor(.cyan)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// MARK: - 창작 캐릭터 카드 (그리드용)
struct CreativeCharacterCard: View {
    let character: GeneratedCharacter
    let delay: Double
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var isVisible = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            onTap()
        }) {
            VStack(spacing: 12) {
                // 캐릭터 아이콘 및 배경
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.2),
                                    Color.purple.opacity(0.3),
                                    Color.pink.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 100)
                    
                    Image(systemName: "person.crop.artframe")
                        .font(.system(size: 40, weight: .light))
                        .foregroundColor(.white)
                }
                
                // 캐릭터 정보
                VStack(spacing: 6) {
                    Text(character.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(character.appearance.prefix(50))
                        .font(.system(size: 12, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text(character.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.cyan.opacity(0.8))
                }
                .padding(.horizontal, 8)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(isPressed ? 0.95 : (isVisible ? 1 : 0.8))
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

// MARK: - 창작 캐릭터 리스트 아이템 (리스트용)
struct CreativeCharacterListItem: View {
    let character: GeneratedCharacter
    let delay: Double
    let onTap: () -> Void
    let onDelete: () -> Void
    @State private var isVisible = false
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            onTap()
        }) {
            HStack(spacing: 16) {
                // 캐릭터 아이콘
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.cyan.opacity(0.3),
                                    Color.purple.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "person.crop.artframe")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.white)
                }
                
                // 캐릭터 정보
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Text(character.appearance)
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                    
                    Text(character.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.cyan.opacity(0.8))
                }
                
                Spacer()
                
                // 액션 버튼
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.white.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : (isVisible ? 1 : 0.9))
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

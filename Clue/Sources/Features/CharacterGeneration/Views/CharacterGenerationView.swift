//
//  CharacterGenerationView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 캐릭터 생성 메인 화면
struct CharacterGenerationView: View {
    @EnvironmentObject var navigationRouter: NavigationRouter
    @StateObject private var viewModel = CharacterGenerationViewModel()
    @State private var showingShareSheet = false
    @State private var isAnimating = false
    @State private var headerPulse = false
    @State private var elementsVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 단순 배경
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.15),  // 깊은 네이비
                        Color(red: 0.1, green: 0.1, blue: 0.25),   // 미드나잇 블루
                        Color(red: 0.15, green: 0.15, blue: 0.35)  // 보라빛 네이비
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                // 단순한 떠다니는 요소들
                ForEach(0..<6, id: \.self) { index in
                    SimpleFloatingElement(index: index, geometry: geometry)
                        .opacity(0.1)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 35) {
                        // 단순한 창작 헤더
                        SimpleCreativeHeader()
                            .padding(.top, 30)
                
                        // 창작 요소 선택 섹션
                        Group {
                            if viewModel.isLoadingTaxonomy {
                                SimpleLoadingSection()
                            } else if !viewModel.taxonomyGroups.isEmpty {
                                SimpleHierarchicalView(viewModel: viewModel, elementsVisible: $elementsVisible)
                            } else {
                                SimpleErrorSection(
                                    message: viewModel.taxonomyError ?? "창작 요소를 불러올 수 없습니다"
                                ) {
                                    viewModel.retryLoadingTaxonomy()
                                }
                            }
                        }
                
                        // 단순한 창작 설정 요약
                        SimpleSettingsSummary(
                            settingsDescription: viewModel.settingsDescription,
                            elementsVisible: $elementsVisible
                        )
                
                        // 단순한 창작 액션 버튼들
                        SimpleActionButtons(viewModel: viewModel)
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setNavigationRouter(navigationRouter)
            viewModel.loadTaxonomyData()
            
            withAnimation(.easeInOut(duration: 0.8)) {
                elementsVisible = true
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                headerPulse = true
            }
        }
        .sheet(isPresented: $viewModel.showingResult) {
            if let character = viewModel.generatedCharacter {
                CharacterResultView(
                    character: character,
                    onDismiss: {
                        viewModel.dismissResult()
                    }
                )
            }
        }
        .alert("생성 오류", isPresented: $viewModel.showingError) {
            Button("확인") { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    

}

// MARK: - 설정 섹션 컴포넌트
struct SettingsSection<Content: View>: View {
    let title: String
    let description: String
    let content: Content
    
    init(title: String, description: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.description = description
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - 확장 가능한 계층적 선택 뷰
struct ExpandableHierarchicalView: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // 진행 상황 표시
            VStack(spacing: 12) {
                HStack {
                    Text("진행 상황")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.progressPercentage * Double(viewModel.availableCategories.count)))/\(viewModel.availableCategories.count)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                // 커스텀 진행률 바
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 배경
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                        
                        // 진행률
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * viewModel.progressPercentage,
                                height: 8
                            )
                            .animation(.easeInOut(duration: 0.3), value: viewModel.progressPercentage)
                    }
                }
                .frame(height: 8)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            
            // 모든 카테고리를 위에서부터 나열
            LazyVStack(spacing: 16) {
                ForEach(viewModel.availableCategories, id: \.self) { category in
                    CategorySection(
                        category: category,
                        viewModel: viewModel
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 카테고리 섹션
struct CategorySection: View {
    let category: TaxonomyCategory
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    private var parentItems: [TaxonomyItem] {
        viewModel.getParentItems(for: category)
    }
    
    private var selectedParent: TaxonomyItem? {
        viewModel.selectedParents[category]
    }
    
    private var isExpanded: Bool {
        viewModel.isCategoryExpanded(category)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // 카테고리 헤더
            HStack {
                HStack(spacing: 12) {
                    // 카테고리 아이콘
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: selectedParent != nil ? [.blue, .purple] : [.gray.opacity(0.3), .gray.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: getCategoryIcon(category))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedParent != nil ? .white : .gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.displayName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text(category.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if let selected = selectedParent {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("선택됨")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue)
                            .textCase(.uppercase)
                        
                        Text(selected.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.blue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedParent != nil ? 
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: selectedParent != nil ? 2 : 1
                            )
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
            )
            
            // 특별 옵션들 ('무작위' 선택, 직접 입력)
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // '무작위' 선택 버튼
                    Button(action: {
                        viewModel.selectAllForCategory(category)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.isSelectAllActive(for: category) ? .white : .blue)
                            
                            Text("무작위")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.isSelectAllActive(for: category) ? Color.white : .primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    viewModel.isSelectAllActive(for: category) ?
                                    LinearGradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.isSelectAllActive(for: category) ? 
                                            LinearGradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                            LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing),
                                            lineWidth: viewModel.isSelectAllActive(for: category) ? 2 : 1
                                        )
                                )
                                .shadow(
                                    color: viewModel.isSelectAllActive(for: category) ? .blue.opacity(0.3) : .clear,
                                    radius: viewModel.isSelectAllActive(for: category) ? 6 : 0,
                                    x: 0,
                                    y: viewModel.isSelectAllActive(for: category) ? 3 : 0
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 직접 입력 버튼
                    Button(action: {
                        viewModel.toggleCustomInput(for: category)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.isCustomInputActive(for: category) ? .white : .orange)
                            
                            Text("직접 입력")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.isCustomInputActive(for: category) ? Color.white : .primary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    viewModel.isCustomInputActive(for: category) ?
                                    LinearGradient(colors: [Color.orange.opacity(0.9), Color.orange.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.isCustomInputActive(for: category) ? 
                                            LinearGradient(colors: [.orange.opacity(0.8), .red.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                            LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing),
                                            lineWidth: viewModel.isCustomInputActive(for: category) ? 2 : 1
                                        )
                                )
                                .shadow(
                                    color: viewModel.isCustomInputActive(for: category) ? .orange.opacity(0.3) : .clear,
                                    radius: viewModel.isCustomInputActive(for: category) ? 6 : 0,
                                    x: 0,
                                    y: viewModel.isCustomInputActive(for: category) ? 3 : 0
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                
                // 직접 입력 텍스트 필드
                if viewModel.isCustomInputActive(for: category) {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "text.cursor")
                                .font(.system(size: 14))
                                .foregroundColor(.orange)
                            
                            Text("원하는 \(category.displayName.lowercased())을 입력하세요")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                        
                        TextField(getPlaceholder(for: category), text: Binding(
                            get: { viewModel.getCustomInput(for: category) },
                            set: { viewModel.updateCustomInput(for: category, text: $0) }
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16, weight: .medium))
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.5), lineWidth: 2)
                            )
                            .shadow(color: Color.orange.opacity(0.2), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                }
            }
            
            // 부모 아이템들 (특별 옵션이 선택되지 않은 경우에만 표시)
            if !viewModel.isSelectAllActive(for: category) && !viewModel.isCustomInputActive(for: category) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(parentItems, id: \.id) { item in
                        ParentItemCard(
                            item: item,
                            isSelected: selectedParent?.id == item.id,
                            hasChildren: !viewModel.getChildItems(for: item).isEmpty
                        ) {
                            viewModel.selectParentItem(item)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            
            // 자식 아이템들 (특별 옵션이 선택되지 않고, 선택된 부모가 있고 확장된 경우에만 표시)
            if !viewModel.isSelectAllActive(for: category) && !viewModel.isCustomInputActive(for: category),
               let parent = selectedParent, isExpanded {
                let childItems = viewModel.getChildItems(for: parent)
                if !childItems.isEmpty {
                    VStack(spacing: 16) {
                        // 구분선과 제목
                        VStack(spacing: 12) {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [.clear, .blue.opacity(0.3), .clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 1)
                            
                            HStack {
                                Image(systemName: "arrow.down.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.blue)
                                
                                Text("\(parent.name)의 하위 옵션")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                Text("\(childItems.count)개")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(Color(.systemGray5))
                                    )
                            }
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 12) {
                            ForEach(childItems, id: \.id) { child in
                                ChildItemCard(
                                    item: child,
                                    isSelected: getSelectedId(for: category) == child.id
                                ) {
                                    viewModel.selectChildItem(child)
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.blue.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                    .padding(.horizontal, 20)
                }
            }
        }
        .padding(.vertical, 12)
    }
    
    private func getCategoryIcon(_ category: TaxonomyCategory) -> String {
        switch category {
        case .gender: return "person.2.fill"
        case .genre: return "theatermasks"
        case .theme: return "lightbulb"
        case .era: return "clock"
        case .mood: return "heart"
        case .personality: return "person"
        case .origin: return "house"
        case .weakness: return "exclamationmark.triangle"
        case .motivation: return "target"
        case .goal: return "flag"
        case .twist: return "shuffle"
        }
    }
    
    private func getSelectedId(for category: TaxonomyCategory) -> Int? {
        switch category {
        case .gender: return viewModel.selectedGenderId
        case .genre: return viewModel.selectedGenreId
        case .theme: return viewModel.selectedThemeId
        case .era: return viewModel.selectedEraId
        case .mood: return viewModel.selectedMoodId
        case .personality: return viewModel.selectedPersonalityId
        case .origin: return viewModel.selectedOriginId
        case .weakness: return viewModel.selectedWeaknessId
        case .motivation: return viewModel.selectedMotivationId
        case .goal: return viewModel.selectedGoalId
        case .twist: return viewModel.selectedTwistId
        }
    }
    
    private func getPlaceholder(for category: TaxonomyCategory) -> String {
        switch category {
        case .gender: return "예: 남성, 여성, 논바이너리 등"
        case .genre: return "예: 판타지, SF, 로맨스, 스릴러 등"
        case .theme: return "예: 성장, 복수, 사랑, 우정 등"
        case .era: return "예: 현대, 중세, 미래, 조선시대 등"
        case .mood: return "예: 밝은, 어두운, 신비로운, 코믹한 등"
        case .personality: return "예: 용감한, 내성적인, 유머러스한 등"
        case .origin: return "예: 귀족, 평민, 외계인, 마법사 등"
        case .weakness: return "예: 고소공포증, 과거의 트라우마 등"
        case .motivation: return "예: 가족을 구하기, 세상을 바꾸기 등"
        case .goal: return "예: 왕이 되기, 진실 찾기, 사랑 얻기 등"
        case .twist: return "예: 실제로는 악역, 기억을 잃음 등"
        }
    }
}

// MARK: - 부모 아이템 카드
struct ParentItemCard: View {
    let item: TaxonomyItem
    let isSelected: Bool
    let hasChildren: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.name)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(isSelected ? Color.white : .primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        if hasChildren {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(isSelected ? Color.white.opacity(0.95) : .blue)
                                
                                Text("하위 옵션")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(isSelected ? Color.white.opacity(0.95) : .blue)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color.white)
                            .background(
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 24, height: 24)
                            )
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? 
                        LinearGradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? 
                                LinearGradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 3 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 12 : 4,
                        x: 0,
                        y: isSelected ? 6 : 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - 자식 아이템 카드
struct ChildItemCard: View {
    let item: TaxonomyItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Text(item.name)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundColor(isSelected ? Color.white : .primary)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color.white)
                        .background(
                            Circle()
                                .fill(Color.green)
                                .frame(width: 18, height: 18)
                        )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected ? 
                        LinearGradient(colors: [Color.blue.opacity(0.9), Color.blue.opacity(0.7)], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSelected ? 
                                LinearGradient(colors: [.blue.opacity(0.8), .purple.opacity(0.8)], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.4) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 2,
                        x: 0,
                        y: isSelected ? 4 : 1
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - 단순한 떠다니는 요소
struct SimpleFloatingElement: View {
    let index: Int
    let geometry: GeometryProxy
    @State private var offset = CGSize.zero
    
    var body: some View {
        let symbols = ["✨", "🎨", "🎭", "✏️", "🌟", "⚡"]
        
        // 안전한 범위 계산
        let minX: CGFloat = 50
        let maxX = max(minX + 1, geometry.size.width - 50)
        let minY: CGFloat = 100
        let maxY = max(minY + 1, geometry.size.height - 100)
        
        Text(symbols[index % symbols.count])
            .font(.system(size: 20))
            .foregroundColor(.white.opacity(0.3))
            .offset(offset)
            .position(
                x: CGFloat.random(in: minX...maxX),
                y: CGFloat.random(in: minY...maxY)
            )
            .onAppear {
                let delay = Double.random(in: 0...2)
                let duration = Double.random(in: 4...6)
                
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                    .delay(delay)
                ) {
                    offset = CGSize(
                        width: CGFloat.random(in: -30...30),
                        height: CGFloat.random(in: -40...40)
                    )
                }
            }
    }
}

// MARK: - 단순한 창작 헤더
struct SimpleCreativeHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            // 단순한 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
            }
            
            // 단순한 타이틀
            VStack(spacing: 12) {
                Text("캐릭터 창작소")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("AI와 함께 독창적인 캐릭터를 만들어보세요")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 로딩 섹션
struct CreativeLoadingSection: View {
    var body: some View {
        VStack(spacing: 24) {
            ForEach(0..<3, id: \.self) { index in
                VStack(spacing: 16) {
                    HStack {
                        // 로딩 아이콘
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 50, height: 50)
                            
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 120, height: 16)
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 80, height: 12)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 0.5).delay(Double(index) * 0.2)) {
                        // 애니메이션 효과
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 에러 섹션
struct CreativeErrorSection: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            // 에러 아이콘
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.2), .orange.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 12) {
                Text("창작 요소 로딩 실패")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: retryAction) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("다시 시도")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    LinearGradient(
                        colors: [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadow(color: .orange.opacity(0.4), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.red.opacity(0.3), .orange.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 계층 뷰
struct CreativeHierarchicalView: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    @Binding var elementsVisible: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 창작 진행률
            CreativeProgressSection(viewModel: viewModel)
            
            // 전체 '무작위' 선택 버튼
            GlobalSelectAllButton(viewModel: viewModel)
            
            // 카테고리들
            LazyVStack(spacing: 20) {
                ForEach(Array(viewModel.availableCategories.enumerated()), id: \.element) { index, category in
                    CreativeCategoryCard(
                        category: category,
                        viewModel: viewModel,
                        index: index
                    )
                    .opacity(elementsVisible ? 1 : 0)
                    .offset(y: elementsVisible ? 0 : 50)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                        .delay(Double(index) * 0.1),
                        value: elementsVisible
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 진행률 섹션
struct CreativeProgressSection: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.cyan)
                    
                    Text("창작 진행률")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(Int(viewModel.progressPercentage * Double(viewModel.availableCategories.count)))/\(viewModel.availableCategories.count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [.cyan, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }
            
            // 진행률 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(
                            width: geometry.size.width * viewModel.progressPercentage,
                            height: 12
                        )
                        .animation(.spring(response: 0.8, dampingFraction: 0.8), value: viewModel.progressPercentage)
                        .shadow(color: .cyan.opacity(0.5), radius: 4, x: 0, y: 2)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [.cyan.opacity(0.3), .purple.opacity(0.3)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - 창작 카테고리 카드 
struct CreativeCategoryCard: View {
    let category: TaxonomyCategory
    @ObservedObject var viewModel: CharacterGenerationViewModel
    let index: Int
    
    var body: some View {
        CategorySection(category: category, viewModel: viewModel)
    }
}

// MARK: - 창작 설정 요약
struct CreativeSettingsSummary: View {
    let settingsDescription: String
    @Binding var elementsVisible: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "list.bullet.clipboard.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.pink)
                    
                    Text("선택된 창작 요소")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                Text(settingsDescription)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.08))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.pink.opacity(0.3), .purple.opacity(0.3)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                    )
                    .shadow(color: .pink.opacity(0.2), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 20)
        .opacity(elementsVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.8).delay(0.5), value: elementsVisible)
    }
}

// MARK: - 전체 '무작위' 선택 버튼
struct GlobalSelectAllButton: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    @State private var buttonPulse = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                buttonPulse = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                buttonPulse = false
            }
            
            if viewModel.isAllCategoriesSelected {
                viewModel.deselectAllCategories()
            } else {
                                    viewModel.selectAllCategoriesGlobally()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isAllCategoriesSelected ? "checkmark.circle.fill" : "circle.grid.3x3.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text(viewModel.isAllCategoriesSelected ? "전체 선택 해제" : "모든 영역 '무작위'로 선택")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.selectAllCategories.count)/\(viewModel.availableCategories.count)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: viewModel.isAllCategoriesSelected ? 
                                [.green, .green.opacity(0.8)] : 
                                [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
            .shadow(
                color: viewModel.isAllCategoriesSelected ? .green.opacity(0.4) : .orange.opacity(0.4),
                radius: 12,
                x: 0,
                y: 6
            )
            .scaleEffect(buttonPulse ? 0.98 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

// MARK: - 창작 액션 버튼들
struct CreativeActionButtons: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    @State private var generatePulse = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 메인 생성 버튼
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    generatePulse = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    generatePulse = false
                }
                
                viewModel.generateCharacter()
            }) {
                HStack(spacing: 12) {
                    if viewModel.isGenerating {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                .frame(width: 20, height: 20)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color.white, lineWidth: 2)
                                .frame(width: 20, height: 20)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: UUID())
                        }
                        
                        Text("창작 중...")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    } else {
                        Image(systemName: "person.crop.artframe")
                            .font(.system(size: 20, weight: .medium))
                        
                        Text("캐릭터 창조하기")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    Group {
                        if viewModel.canGenerate {
                            LinearGradient(
                                colors: [.cyan, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            LinearGradient(
                                colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            viewModel.canGenerate ? 
                            LinearGradient(colors: [.white.opacity(0.3)], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: viewModel.canGenerate ? .cyan.opacity(0.4) : .clear,
                    radius: viewModel.canGenerate ? 12 : 0,
                    x: 0,
                    y: viewModel.canGenerate ? 6 : 0
                )
                .scaleEffect(generatePulse ? 0.95 : (viewModel.canGenerate ? 1.0 : 0.95))
            }
            .disabled(!viewModel.canGenerate || viewModel.isGenerating)
            
            // 초기화 버튼
            Button(action: {
                viewModel.resetHierarchicalSelection()
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("창작 설정 초기화")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

// MARK: - 단순한 로딩 섹션
struct SimpleLoadingSection: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(1.5)
            
            Text("창작 요소를 불러오는 중...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.vertical, 40)
    }
}

// MARK: - 단순한 에러 섹션
struct SimpleErrorSection: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48, weight: .medium))
                .foregroundColor(.red)
            
            VStack(spacing: 12) {
                Text("로딩 실패")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            
            Button(action: retryAction) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                    
                    Text("다시 시도")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.red)
                .clipShape(Capsule())
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 40)
    }
}

// MARK: - 단순한 계층 뷰
struct SimpleHierarchicalView: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    @Binding var elementsVisible: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 단순한 진행률
            SimpleProgressSection(viewModel: viewModel)
            
            // 단순한 전체 선택 버튼
            SimpleGlobalSelectButton(viewModel: viewModel)
            
            // 카테고리들
            LazyVStack(spacing: 20) {
                ForEach(Array(viewModel.availableCategories.enumerated()), id: \.element) { index, category in
                    CategorySection(
                        category: category,
                        viewModel: viewModel
                    )
                    .opacity(elementsVisible ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .delay(Double(index) * 0.1),
                        value: elementsVisible
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - 단순한 진행률 섹션
struct SimpleProgressSection: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("진행률")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(Int(viewModel.progressPercentage * Double(viewModel.availableCategories.count)))/\(viewModel.availableCategories.count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            
            // 단순한 진행률 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(
                            width: geometry.size.width * viewModel.progressPercentage,
                            height: 12
                        )
                        .animation(.easeInOut(duration: 0.3), value: viewModel.progressPercentage)
                }
            }
            .frame(height: 12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
    }
}

// MARK: - 단순한 전체 선택 버튼
struct SimpleGlobalSelectButton: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    var body: some View {
        Button(action: {
            if viewModel.isAllCategoriesSelected {
                viewModel.deselectAllCategories()
            } else {
                viewModel.selectAllCategoriesGlobally()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: viewModel.isAllCategoriesSelected ? "checkmark.circle.fill" : "circle.grid.3x3.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                
                Text(viewModel.isAllCategoriesSelected ? "전체 선택 해제" : "모든 영역 '무작위'로 선택")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(viewModel.selectAllCategories.count)/\(viewModel.availableCategories.count)")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                    )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        viewModel.isAllCategoriesSelected ? 
                            Color.green : Color.orange
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 단순한 설정 요약
struct SimpleSettingsSummary: View {
    let settingsDescription: String
    @Binding var elementsVisible: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("선택된 요소")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(settingsDescription.isEmpty ? "아직 선택된 요소가 없습니다." : settingsDescription)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.8))
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                )
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .opacity(elementsVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.5).delay(0.3), value: elementsVisible)
    }
}

// MARK: - 단순한 액션 버튼들
struct SimpleActionButtons: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // 메인 생성 버튼
            Button(action: {
                viewModel.generateCharacter()
            }) {
                HStack(spacing: 12) {
                    if viewModel.isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        
                        Text("생성 중...")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    } else {
                        Image(systemName: "person.crop.artframe")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        Text("캐릭터 생성하기")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(
                    viewModel.canGenerate ? Color.blue : Color.gray
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(!viewModel.canGenerate || viewModel.isGenerating)
            .buttonStyle(PlainButtonStyle())
            
            // 초기화 버튼
            Button(action: {
                viewModel.resetHierarchicalSelection()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("초기화")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.1))
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

// MARK: - 시머 효과 확장
extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.4),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(30))
                .offset(x: phase)
                .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: phase)
            )
            .onAppear {
                phase = 300
            }
    }
}

#Preview {
    NavigationView {
        CharacterGenerationView()
            .environmentObject(NavigationRouter())
    }
} 


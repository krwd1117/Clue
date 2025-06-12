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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 헤더
                VStack(spacing: 20) {
                    // 아이콘과 제목
                    VStack(spacing: 16) {
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
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 8) {
                            Text("캐릭터 생성")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.primary, .secondary],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("10가지 요소를 선택하여 독특한 캐릭터를 만들어보세요")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(.top, 20)
                
                // 계층적 선택 섹션
                if viewModel.isLoadingTaxonomy {
                    VStack(spacing: 20) {
                        ForEach(0..<3, id: \.self) { _ in
                            TaxonomyLoadingView()
                        }
                    }
                } else if !viewModel.taxonomyGroups.isEmpty {
                    ExpandableHierarchicalView(viewModel: viewModel)
                } else {
                    TaxonomyErrorView(
                        message: viewModel.taxonomyError ?? "데이터를 불러올 수 없습니다"
                    ) {
                        viewModel.retryLoadingTaxonomy()
                    }
                }
                
                // 선택된 설정 요약
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.system(size: 18))
                            .foregroundColor(.blue)
                        
                        Text("선택된 설정")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text(viewModel.settingsDescription)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                }
                .padding(.horizontal, 20)
                
                // 생성 버튼
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.generateCharacter()
                    }) {
                        HStack(spacing: 12) {
                            if viewModel.isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.9)
                                Text("생성 중...")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            } else {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 20, weight: .medium))
                                Text("캐릭터 생성하기")
                                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            viewModel.canGenerate ? 
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                            LinearGradient(colors: [.gray], startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(
                            color: viewModel.canGenerate ? .blue.opacity(0.3) : .clear,
                            radius: viewModel.canGenerate ? 8 : 0,
                            x: 0,
                            y: viewModel.canGenerate ? 4 : 0
                        )
                    }
                    .disabled(!viewModel.canGenerate)
                    .scaleEffect(viewModel.canGenerate ? 1.0 : 0.95)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.canGenerate)
                    
                    Button(action: {
                        viewModel.resetHierarchicalSelection()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 14, weight: .medium))
                            Text("설정 초기화")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemGray6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
            .padding(.bottom, 40)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .navigationTitle("캐릭터 생성")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setNavigationRouter(navigationRouter)
            viewModel.loadTaxonomyData()
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
            
            // 특별 옵션들 ('모두' 선택, 직접 입력)
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // '모두' 선택 버튼
                    Button(action: {
                        viewModel.selectAllForCategory(category)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.isSelectAllActive(for: category) ? .white : .blue)
                            
                            Text("모두")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    viewModel.isSelectAllActive(for: category) ?
                                    LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.isSelectAllActive(for: category) ? Color.clear : Color(.systemGray4),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .foregroundColor(viewModel.isSelectAllActive(for: category) ? .white : .primary)
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
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    viewModel.isCustomInputActive(for: category) ?
                                    LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing) :
                                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(
                                            viewModel.isCustomInputActive(for: category) ? Color.clear : Color(.systemGray4),
                                            lineWidth: 1
                                        )
                                )
                        )
                        .foregroundColor(viewModel.isCustomInputActive(for: category) ? .white : .primary)
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
                        
                        TextField("예: 사이버펑크, 로맨스, 현대 등", text: Binding(
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
                            .fill(Color.orange.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
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
                                .padding(.horizontal, 20)
                            
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
                            .padding(.horizontal, 20)
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
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .padding(.vertical, 12)
    }
    
    private func getCategoryIcon(_ category: TaxonomyCategory) -> String {
        switch category {
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
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        if hasChildren {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                                
                                Text("하위 옵션")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected ? 
                        LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [Color(.systemBackground)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? 
                                LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [Color(.systemGray4)], startPoint: .leading, endPoint: .trailing),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.2) : .black.opacity(0.05),
                        radius: isSelected ? 8 : 4,
                        x: 0,
                        y: isSelected ? 4 : 2
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
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected ? 
                        LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isSelected ? Color.clear : Color(.systemGray4),
                                lineWidth: 1
                            )
                    )
                    .shadow(
                        color: isSelected ? .blue.opacity(0.3) : .black.opacity(0.05),
                        radius: isSelected ? 6 : 2,
                        x: 0,
                        y: isSelected ? 3 : 1
                    )
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview {
    NavigationView {
        CharacterGenerationView()
            .environmentObject(NavigationRouter())
    }
    } 

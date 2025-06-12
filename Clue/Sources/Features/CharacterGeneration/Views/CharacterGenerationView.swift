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
    @State private var elementsVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea(.all)
                
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // 심플한 헤더
                        TossCreativeHeader()
                            .padding(.top, 20)
                
                        // 창작 요소 선택 섹션
                        Group {
                            if viewModel.isLoadingTaxonomy {
                                TossLoadingSection()
                            } else if !viewModel.taxonomyGroups.isEmpty {
                                TossHierarchicalView(viewModel: viewModel, elementsVisible: $elementsVisible)
                            } else {
                                TossErrorSection(
                                    message: viewModel.taxonomyError ?? "창작 요소를 불러올 수 없습니다"
                                ) {
                                    viewModel.retryLoadingTaxonomy()
                                }
                            }
                        }
                
                        // 창작 설정 요약
                        TossSettingsSummary(
                            settingsDescription: viewModel.settingsDescription,
                            elementsVisible: $elementsVisible
                        )
                
                        // 액션 버튼들
                        TossActionButtons(viewModel: viewModel)
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

// MARK: - Toss 스타일 헤더
struct TossCreativeHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            // 심플한 아이콘
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.blue)
            }
            
            // 심플한 타이틀
            VStack(spacing: 12) {
                Text("캐릭터 창작소")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("AI와 함께 독창적인 캐릭터를 만들어보세요")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Toss 스타일 로딩 섹션
struct TossLoadingSection: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(1.2)
            
            Text("창작 요소를 불러오는 중...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - Toss 스타일 에러 섹션
struct TossErrorSection: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 12) {
                Text("로딩 실패")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text(message)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.gray)
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
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 40)
        .padding(.horizontal, 20)
    }
}

// MARK: - Toss 스타일 계층 뷰
struct TossHierarchicalView: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    @Binding var elementsVisible: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // 진행률
            TossProgressSection(viewModel: viewModel)
            
            // 전체 선택 버튼
            TossGlobalSelectButton(viewModel: viewModel)
            
            // 카테고리들
            LazyVStack(spacing: 16) {
                ForEach(Array(viewModel.availableCategories.enumerated()), id: \.element) { index, category in
                    TossCategorySection(
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

// MARK: - Toss 스타일 진행률 섹션
struct TossProgressSection: View {
    @ObservedObject var viewModel: CharacterGenerationViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("진행률")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
                
                Text("\(Int(viewModel.progressPercentage * Double(viewModel.availableCategories.count)))/\(viewModel.availableCategories.count)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
            
            // 진행률 바
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
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
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - Toss 스타일 전체 선택 버튼
struct TossGlobalSelectButton: View {
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
                    .foregroundColor(.white.opacity(0.9))
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
                            Color.green : Color.blue
                    )
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Toss 스타일 카테고리 섹션
struct TossCategorySection: View {
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
                    ZStack {
                        Circle()
                            .fill(selectedParent != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: getCategoryIcon(category))
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedParent != nil ? .blue : .gray)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.displayName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.black)
                        
                        Text(category.description)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                if let selected = selectedParent {
                    Text(selected.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                selectedParent != nil ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2),
                                lineWidth: selectedParent != nil ? 2 : 1
                            )
                    )
            )
            
            // 특별 옵션들
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // 무작위 선택 버튼
                    Button(action: {
                        viewModel.selectAllForCategory(category)
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(viewModel.isSelectAllActive(for: category) ? .white : .blue)
                            
                            Text("무작위")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.isSelectAllActive(for: category) ? .white : .black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.isSelectAllActive(for: category) ? Color.blue : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                                .foregroundColor(viewModel.isCustomInputActive(for: category) ? .white : .black)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.isCustomInputActive(for: category) ? Color.orange : Color.gray.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
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
                            Text("원하는 \(category.displayName.lowercased())을 입력하세요")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                            
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
                            .fill(Color.orange.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }
            }
            
            // 부모 아이템들
            if !viewModel.isSelectAllActive(for: category) && !viewModel.isCustomInputActive(for: category) {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                    ForEach(parentItems, id: \.id) { item in
                        TossParentItemCard(
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
            
            // 자식 아이템들
            if !viewModel.isSelectAllActive(for: category) && !viewModel.isCustomInputActive(for: category),
               let parent = selectedParent, isExpanded {
                let childItems = viewModel.getChildItems(for: parent)
                if !childItems.isEmpty {
                    VStack(spacing: 16) {
                        HStack {
                            Text("\(parent.name)의 하위 옵션")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Text("\(childItems.count)개")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.gray.opacity(0.1))
                                )
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 12) {
                            ForEach(childItems, id: \.id) { child in
                                TossChildItemCard(
                                    item: child,
                                    isSelected: getSelectedId(for: category) == child.id
                                ) {
                                    viewModel.selectChildItem(child)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                            )
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

// MARK: - Toss 스타일 부모 아이템 카드
struct TossParentItemCard: View {
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
                            .foregroundColor(isSelected ? .white : .black)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                        
                        if hasChildren {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.down.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(isSelected ? .white.opacity(0.8) : .blue)
                                
                                Text("하위 옵션")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(isSelected ? .white.opacity(0.8) : .blue)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.white)
                    .shadow(color: .black.opacity(0.05), radius: isSelected ? 8 : 4, x: 0, y: isSelected ? 4 : 2)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                isSelected ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Toss 스타일 자식 아이템 카드
struct TossChildItemCard: View {
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
                    .foregroundColor(isSelected ? .white : .black)
                
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
                    .fill(isSelected ? Color.blue : Color.white)
                    .shadow(color: .black.opacity(0.05), radius: isSelected ? 4 : 2, x: 0, y: isSelected ? 2 : 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Toss 스타일 설정 요약
struct TossSettingsSummary: View {
    let settingsDescription: String
    @Binding var elementsVisible: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("선택된 요소")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Spacer()
            }
            
            Text(settingsDescription.isEmpty ? "아직 선택된 요소가 없습니다." : settingsDescription)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.gray)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                        )
                )
                .multilineTextAlignment(.leading)
        }
        .padding(.horizontal, 20)
        .opacity(elementsVisible ? 1 : 0)
        .animation(.easeInOut(duration: 0.5).delay(0.3), value: elementsVisible)
    }
}

// MARK: - Toss 스타일 액션 버튼들
struct TossActionButtons: View {
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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(viewModel.canGenerate ? Color.blue : Color.gray)
                        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                )
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
                        .foregroundColor(.gray)
                    
                    Text("초기화")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}

#Preview {
    NavigationView {
        CharacterGenerationView()
            .environmentObject(NavigationRouter())
    }
} 


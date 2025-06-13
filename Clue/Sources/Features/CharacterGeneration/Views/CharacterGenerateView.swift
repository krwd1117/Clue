import SwiftUI

struct CharacterGenerateView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CharacterGenerationViewModel()
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with progress
                headerSection
                
                if viewModel.isLoadingCategories {
                    loadingSection
                } else if !viewModel.categories.isEmpty {
                    // Main content
                    ScrollView {
                        VStack(spacing: DesignSystem.Spacing.xl) {
                            // Character name input (always visible)
                            nameInputSection
                            
                            // Current category selection
                            if let currentCategory = viewModel.currentCategory {
                                categorySelectionSection(for: currentCategory)
                            }
                            
                            // Character preview
                            characterPreviewSection
                            
                            Spacer(minLength: DesignSystem.Spacing.xl)
                        }
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.md)
                    }
                    
                    // Bottom navigation
                    bottomNavigationSection
                }
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("캐릭터 생성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                }
            }
            .onAppear {
                Task {
                    await viewModel.loadCategories()
                }
            }
            .alert("캐릭터 생성 완료", isPresented: $showSuccessAlert) {
                Button("확인") {
                    dismiss()
                }
            } message: {
                Text("새로운 캐릭터가 성공적으로 생성되었습니다!")
            }
            .alert("오류", isPresented: .constant(viewModel.error != nil)) {
                Button("확인") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("새로운 캐릭터를 만들어보세요")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                if let currentCategory = viewModel.currentCategory {
                    Text("\(currentCategory.name)을(를) 선택해주세요")
                        .font(.system(size: 16, weight: .medium, design: .default))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            
                            // Progress section with Toss-style design
            if !viewModel.categories.isEmpty {
                TossProgressCard(
                    title: "진행률",
                    subtitle: "\(viewModel.completedCategoriesCount)/\(viewModel.categories.count) 완료",
                    progress: viewModel.progressPercentage
                )
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.lg)
        .background(DesignSystem.Colors.background)
    }
    
    // MARK: - Loading Section
    private var loadingSection: some View {
        TossLoadingView(
            title: "카테고리를 불러오는 중...",
            subtitle: "잠시만 기다려주세요",
            style: .fullscreen
        )
    }
    
    // MARK: - Name Input Section
    private var nameInputSection: some View {
        TossTextFieldCard(
            title: "캐릭터 이름",
            placeholder: "이름을 입력하세요",
            text: $viewModel.characterName,
            isRequired: true,
            showValidation: true
        )
    }
    
    // MARK: - Category Selection Section
    private func categorySelectionSection(for category: CharacterCategory) -> some View {
        TossCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.name)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                        
                        if let description = category.description {
                            Text(description)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    let selectedOption = viewModel.getSelectedOption(for: category)
                    if selectedOption != nil {
                        ZStack {
                            Circle()
                                .fill(DesignSystem.Colors.primary.opacity(0.1))
                                .frame(width: 32, height: 32)
                            
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                    }
                }
                
                if viewModel.isLoadingOptions {
                    TossLoadingView(
                        title: "옵션을 불러오는 중...",
                        style: .inline
                    )
                    .frame(height: 80)
                } else {
                    let options = viewModel.getOptions(for: category)
                    let selectedOption = viewModel.getSelectedOption(for: category)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: DesignSystem.Spacing.md) {
                        ForEach(options) { option in
                            TossOptionButton(
                                title: option.value,
                                isSelected: selectedOption?.id == option.id
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectOption(option, for: category)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Character Preview Section
    private var characterPreviewSection: some View {
        TossCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                HStack {
                    Text("미리보기")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.textPrimary)
                    
                    Spacer()
                    
                    Text("\(viewModel.completedCategoriesCount)개 선택됨")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.textSecondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(DesignSystem.Colors.sectionBackground)
                        .cornerRadius(8)
                }
                
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Character avatar with enhanced design
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            DesignSystem.Colors.primary.opacity(0.1),
                                            DesignSystem.Colors.primary.opacity(0.05)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(DesignSystem.Colors.primary.opacity(0.2), lineWidth: 2)
                                )
                            
                            Image(systemName: "person.fill")
                                .font(.system(size: 40, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        // Character name with better styling
                        Text(viewModel.characterName.isEmpty ? "캐릭터 이름" : viewModel.characterName)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(viewModel.characterName.isEmpty ? DesignSystem.Colors.textTertiary : DesignSystem.Colors.textPrimary)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Selected options with improved cards
                    if !viewModel.categorySelections.filter({ $0.isComplete }).isEmpty {
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            ForEach(viewModel.categorySelections.filter { $0.isComplete }, id: \.category.id) { selection in
                                HStack(spacing: DesignSystem.Spacing.md) {
                                    // Category icon
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(DesignSystem.Colors.primary.opacity(0.1))
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(DesignSystem.Colors.primary)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(selection.category.name)
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(DesignSystem.Colors.textSecondary)
                                        
                                        Text(selection.selectedOption?.value ?? "")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(DesignSystem.Colors.textPrimary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(DesignSystem.Spacing.md)
                                .background(DesignSystem.Colors.sectionBackground)
                                .cornerRadius(12)
                            }
                        }
                    } else {
                        TossEmptyStateView(
                            title: "선택을 완료하면\n여기에 미리보기가 표시됩니다",
                            icon: "sparkles"
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Bottom Navigation Section
    private var bottomNavigationSection: some View {
        VStack(spacing: 0) {
            // Subtle separator
            LinearGradient(
                gradient: Gradient(colors: [
                    DesignSystem.Colors.border.opacity(0.3),
                    DesignSystem.Colors.border,
                    DesignSystem.Colors.border.opacity(0.3)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            
            VStack(spacing: DesignSystem.Spacing.lg) {
                // Step indicator dots
                HStack(spacing: 8) {
                    ForEach(0..<viewModel.categories.count, id: \.self) { index in
                        Circle()
                            .fill(index <= viewModel.currentCategoryIndex ? DesignSystem.Colors.primary : DesignSystem.Colors.sectionBackground)
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == viewModel.currentCategoryIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: viewModel.currentCategoryIndex)
                    }
                }
                .padding(.top, DesignSystem.Spacing.md)
                
                HStack(spacing: DesignSystem.Spacing.md) {
                    // Previous button
                    if !viewModel.isFirstCategory {
                        TossButton(
                            title: "이전",
                            icon: "chevron.left",
                            style: .secondary
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.previousCategory()
                            }
                        }
                    }
                    
                    // Next/Create button
                    if viewModel.isLastCategory {
                        TossButton(
                            title: "캐릭터 생성하기",
                            icon: "sparkles",
                            style: .primary,
                            isLoading: viewModel.isCreatingCharacter,
                            isDisabled: !viewModel.canCreateCharacter
                        ) {
                            Task {
                                let success = await viewModel.createCharacter()
                                if success {
                                    showSuccessAlert = true
                                }
                            }
                        }
                    } else {
                        let canProceed = viewModel.currentCategory.flatMap { viewModel.getSelectedOption(for: $0) } != nil
                        
                        TossButton(
                            title: "다음",
                            icon: "chevron.right",
                            style: .primary,
                            isDisabled: !canProceed
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.nextCategory()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
        }
        .background(DesignSystem.Colors.cardBackground)
    }
}



#Preview {
    CharacterGenerateView()
} 

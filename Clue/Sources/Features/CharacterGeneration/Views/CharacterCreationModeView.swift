import SwiftUI

struct CharacterCreationModeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CharacterGenerationViewModel()
    @State private var showingCustomGeneration = false
    @State private var isGeneratingRandom = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section
                    headerSection
                    
                    // Main Content
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        // Mode Selection Cards
                        modeSelectionSection
                        
                        Spacer(minLength: DesignSystem.Spacing.xl)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                }
            }
            .background(DesignSystem.Colors.background)
        }
        .navigationTitle("캐릭터 생성")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingCustomGeneration) {
            CharacterGenerateView()
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
            Text("무작위 캐릭터가 성공적으로 생성되었습니다!")
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
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("어떤 방식으로\n캐릭터를 만들까요?")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(DesignSystem.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                
                Text("원하는 생성 방식을 선택해주세요")
                    .font(.system(size: 16, weight: .medium, design: .default))
                    .foregroundColor(DesignSystem.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            // Decorative element
            HStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    Circle()
                        .fill(DesignSystem.Colors.primary.opacity(0.3))
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.top, DesignSystem.Spacing.sm)
        }
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .background(DesignSystem.Colors.background)
    }
    
    // MARK: - Mode Selection Section
    private var modeSelectionSection: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Random Generation Card
            TossCard {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Icon and Title
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            DesignSystem.Colors.primary.opacity(0.2),
                                            DesignSystem.Colors.primary.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "shuffle")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("완전 무작위로 생성하기")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("모든 설정이 자동으로 랜덤 선택되어\n빠르게 캐릭터를 생성합니다")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                    }
                    
                    // Features
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        featureRow(icon: "clock", text: "빠른 생성 (약 3초)")
                        featureRow(icon: "sparkles", text: "예상치 못한 조합의 재미")
                        featureRow(icon: "arrow.clockwise", text: "마음에 안 들면 다시 생성 가능")
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Action Button
                    TossButton(
                        title: "무작위로 생성하기",
                        icon: "shuffle",
                        style: .primary,
                        isLoading: isGeneratingRandom,
                        isDisabled: viewModel.categories.isEmpty
                    ) {
                        Task {
                            await generateRandomCharacter()
                        }
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            
            // Custom Generation Card
            TossCard {
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Icon and Title
                    VStack(spacing: DesignSystem.Spacing.md) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            DesignSystem.Colors.secondary.opacity(0.2),
                                            DesignSystem.Colors.secondary.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 32, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.secondary)
                        }
                        
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            Text("직접 선택해서 생성하기")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("각 항목을 하나씩 선택하여\n원하는 대로 캐릭터를 만듭니다")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(DesignSystem.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                    }
                    
                    // Features
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        featureRow(icon: "hand.point.up", text: "세밀한 커스터마이징")
                        featureRow(icon: "eye", text: "실시간 미리보기 제공")
                        featureRow(icon: "pencil", text: "직접 입력 옵션 지원")
                    }
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    
                    // Action Button
                    TossButton(
                        title: "직접 선택하기",
                        icon: "slider.horizontal.3",
                        style: .primary
                    ) {
                        showingCustomGeneration = true
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
    }
    
    // MARK: - Actions
    private func generateRandomCharacter() async {
        isGeneratingRandom = true
        
        // 모든 카테고리에 대해 무작위 옵션 선택
        for category in viewModel.categories {
            viewModel.selectRandomOption(for: category)
        }
        
        // 캐릭터 생성 API 호출
        let success = await viewModel.createCharacter()
        
        isGeneratingRandom = false
        
        if success {
            showSuccessAlert = true
        }
    }
    
    // MARK: - Helper Views
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(DesignSystem.Colors.primary)
                .frame(width: 16, height: 16)
            
            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(DesignSystem.Colors.textSecondary)
            
            Spacer()
        }
    }
}

#Preview {
    CharacterCreationModeView()
} 

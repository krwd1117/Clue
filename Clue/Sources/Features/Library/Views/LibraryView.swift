import SwiftUI

struct LibraryView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Custom segmented control
                HStack(spacing: 0) {
                    TabButton(title: "캐릭터", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    
                    TabButton(title: "시나리오", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.md)
                
                // Content
                TabView(selection: $selectedTab) {
                    CharacterLibraryView()
                        .tag(0)
                    
                    ScenarioLibraryView()
                        .tag(1)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .background(DesignSystem.Colors.background)
            .navigationTitle("보관함")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(DesignSystem.Typography.bodyBold)
                    .foregroundColor(isSelected ? DesignSystem.Colors.primary : DesignSystem.Colors.textSecondary)
                
                Rectangle()
                    .fill(isSelected ? DesignSystem.Colors.primary : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct CharacterLibraryView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                
                // Add new character card
                TossAddNewCard(
                    title: "새 캐릭터",
                    icon: "plus"
                ) {
                    // TODO: Navigate to character creation
                    print("새 캐릭터 생성")
                }
                
                // Sample character cards
                TossContentCard(
                    title: "마법사 엘리아",
                    description: "고대 마법을 다루는 현명한 마법사",
                    icon: "sparkles",
                    iconColor: DesignSystem.Colors.primary
                )
                
                TossContentCard(
                    title: "기사 아서",
                    description: "정의로운 마음을 가진 용감한 기사",
                    icon: "shield",
                    iconColor: DesignSystem.Colors.primary
                )
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}

struct ScenarioLibraryView: View {
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
            ], spacing: DesignSystem.Spacing.md) {
                
                // Add new scenario card
                TossAddNewCard(
                    title: "새 시나리오",
                    icon: "plus"
                ) {
                    // TODO: Navigate to scenario creation
                    print("새 시나리오 생성")
                }
                
                // Sample scenario cards
                TossContentCard(
                    title: "드래곤의 둥지",
                    description: "고대 드래곤이 잠들어 있는 신비로운 동굴",
                    icon: "flame",
                    iconColor: DesignSystem.Colors.accent
                )
                
                TossContentCard(
                    title: "마법의 숲",
                    description: "요정들이 살고 있는 환상적인 숲",
                    icon: "leaf",
                    iconColor: DesignSystem.Colors.accent
                )
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}



#Preview {
    LibraryView()
} 

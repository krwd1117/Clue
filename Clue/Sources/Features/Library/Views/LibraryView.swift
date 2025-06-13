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
                    
//                    TabButton(title: "시나리오", isSelected: selectedTab == 1) {
//                        selectedTab = 1
//                    }
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
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }
}



#Preview {
    LibraryView()
} 

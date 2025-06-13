import SwiftUI



struct HomeView: View {
    @StateObject private var router = HomeRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ScrollView {
                VStack(spacing: DesignSystem.Spacing.xl) {
                    // Header section
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("안녕하세요! 👋")
                            .font(DesignSystem.Typography.title)
                            .foregroundColor(DesignSystem.Colors.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("오늘은 어떤 이야기를 만들어볼까요?")
                            .font(DesignSystem.Typography.body)
                            .foregroundColor(DesignSystem.Colors.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.top, DesignSystem.Spacing.md)
                    
                    // Main action grid
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: DesignSystem.Spacing.md),
                        GridItem(.flexible(), spacing: DesignSystem.Spacing.md)
                    ], spacing: DesignSystem.Spacing.md) {
                        
                        // Character Creation Card
                        TossActionCard(
                            title: "캐릭터 생성",
                            subtitle: "새로운 캐릭터를\n만들어보세요",
                            icon: "person.crop.circle.badge.plus",
                            backgroundColor: DesignSystem.Colors.primary,
                            action: {
                                router.navigate(to: .characterCreationMode)
//                                router.presentSheet(.characterGenerate)
                            }
                        )
                        
                        // Scenario Creation Card
//                        TossActionCard(
//                            title: "시나리오 생성",
//                            subtitle: "흥미진진한 이야기를\n시작해보세요",
//                            icon: "book.pages",
//                            backgroundColor: DesignSystem.Colors.accent,
//                            action: {
//                                router.presentSheet(.scenarioGenerate)
//                            }
//                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer(minLength: DesignSystem.Spacing.xl)
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
            .navigationDestination(for: HomeRoute.self) { route in
                router.navigate(for: route)
            }
            .sheet(item: Binding<HomeRoute?>(
                get: { router.presentedSheet },
                set: { _ in router.dismissSheet() }
            )) { route in
                router.navigate(for: route)
            }
        }
    }
}

#Preview {
    HomeView()
} 

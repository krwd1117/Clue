import SwiftUI

enum HomeRoute {
    case characterGenerate
    case scenarioGenerate
}

class HomeRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: HomeRoute?
    
    func navigate(to route: HomeRoute) {
        path.append(route)
    }
    
    func presentSheet(_ route: HomeRoute) {
        presentedSheet = route
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func navigateBack() {
        path.removeLast()
    }
    
    func navigateToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func navigate(for route: HomeRoute) -> some View {
        switch route {
        case .characterGenerate:
            CharacterGenerateView()
        case .scenarioGenerate:
            Text("시나리오 생성 화면") // TODO: ScenarioGenerateView
                .font(DesignSystem.Typography.title)
        }
    }
}

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
                                router.presentSheet(.characterGenerate)
                            }
                        )
                        
                        // Scenario Creation Card
                        TossActionCard(
                            title: "시나리오 생성",
                            subtitle: "흥미진진한 이야기를\n시작해보세요",
                            icon: "book.pages",
                            backgroundColor: DesignSystem.Colors.accent,
                            action: {
                                router.presentSheet(.scenarioGenerate)
                            }
                        )
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    // Recent section
                    VStack(spacing: DesignSystem.Spacing.md) {
                        HStack {
                            Text("최근 활동")
                                .font(DesignSystem.Typography.headline)
                                .foregroundColor(DesignSystem.Colors.textPrimary)
                            
                            Spacer()
                            
                            Button("전체보기") {
                                // TODO: Show all recent activities
                            }
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.primary)
                        }
                        
                        // Recent items placeholder
                        VStack(spacing: DesignSystem.Spacing.sm) {
                            TossRecentItemCard(
                                title: "마법사 엘리아",
                                subtitle: "캐릭터 • 2시간 전",
                                icon: "sparkles"
                            )
                            
                            TossRecentItemCard(
                                title: "드래곤의 둥지",
                                subtitle: "시나리오 • 1일 전",
                                icon: "book.closed"
                            )
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    
                    Spacer(minLength: DesignSystem.Spacing.xl)
                }
                .padding(.vertical, DesignSystem.Spacing.md)
            }
            .background(DesignSystem.Colors.background)
//            .navigationTitle("홈")
//            .navigationBarTitleDisplayMode(.large)
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

// HomeRoute를 Identifiable로 만들기 위한 extension
extension HomeRoute: Identifiable {
    var id: String {
        switch self {
        case .characterGenerate:
            return "characterGenerate"
        case .scenarioGenerate:
            return "scenarioGenerate"
        }
    }
}

// HomeRoute를 Hashable로 만들기 위한 extension (NavigationPath용)
extension HomeRoute: Hashable {}



#Preview {
    HomeView()
} 

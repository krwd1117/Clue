//
//  MainTabView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 메인 탭 뷰
struct MainTabView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var authService: AuthService
    @StateObject private var navigationRouter = NavigationRouter()
    @StateObject private var viewModel = MainTabViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 첫 번째 탭: 홈
            NavigationStack(path: $navigationRouter.path) {
                HomeView()
                    .navigationDestination(for: AppNavigationPath.self) { destination in
                        navigationRouter.buildView(for: destination)
                    }
            }
            .environmentObject(navigationRouter)
            .tabItem {
                Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                Text("홈")
            }
            .tag(0)
            
            // 두 번째 탭: 내 캐릭터 (그리드)
            SavedCharactersView()
                .environmentObject(navigationRouter)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "person.3.fill" : "person.3")
                    Text("내 캐릭터")
                }
                .tag(1)
            
            // 세 번째 탭: 프로필/설정
            ProfileView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "person.circle.fill" : "person.circle")
                    Text("프로필")
                }
                .tag(2)
        }
        .sheet(item: Binding<AppSheetItem?>(
            get: { navigationRouter.presentedSheet.map(AppSheetItem.init) },
            set: { _ in navigationRouter.dismissSheet() }
        )) { item in
            navigationRouter.buildView(for: item.path)
        }
        .fullScreenCover(item: Binding<AppSheetItem?>(
            get: { navigationRouter.presentedFullScreenCover.map(AppSheetItem.init) },
            set: { _ in navigationRouter.dismissFullScreenCover() }
        )) { item in
            navigationRouter.buildView(for: item.path)
        }
        .onAppear {
            viewModel.setup()
            setupTabBarAppearance()
        }
    }
    
    // MARK: - Tab Bar Appearance Setup
    private func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        
        // 글래스모피즘 효과가 있는 세련된 배경
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.85) // 반투명 네이비
        
        // 블러 효과 추가
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        appearance.backgroundEffect = blurEffect
        
        // 선택된 탭 - 그라데이션 효과가 있는 밝은 색상
        let selectedColor = UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0) // 시안 블루
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: selectedColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .bold),
            .kern: 0.5 // 글자 간격 조정
        ]
        
        // 선택되지 않은 탭 - 우아한 회색
        let normalColor = UIColor(red: 0.65, green: 0.65, blue: 0.75, alpha: 0.9)
        appearance.stackedLayoutAppearance.normal.iconColor = normalColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: normalColor,
            .font: UIFont.systemFont(ofSize: 11, weight: .medium),
            .kern: 0.3
        ]
        
        // 세련된 상단 구분선
        appearance.shadowColor = UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3)
        appearance.shadowImage = createGradientLine()
        
        // 탭바에 적용
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // 고급스러운 반투명 효과
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().barTintColor = UIColor(red: 0.08, green: 0.08, blue: 0.20, alpha: 0.85)
        
        // 추가 스타일링
        UITabBar.appearance().layer.cornerRadius = 0
        UITabBar.appearance().clipsToBounds = true
    }
    
    // MARK: - Helper Methods
    private func createGradientLine() -> UIImage? {
        let size = CGSize(width: UIScreen.main.bounds.width, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.6).cgColor,
            UIColor.clear.cgColor
        ]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 0.5, 1])
        
        if let gradient = gradient {
            context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: 0), options: [])
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: - Sheet Item Wrapper
struct AppSheetItem: Identifiable {
    let id = UUID()
    let path: AppNavigationPath
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
        .environmentObject(AuthService.shared)
} 
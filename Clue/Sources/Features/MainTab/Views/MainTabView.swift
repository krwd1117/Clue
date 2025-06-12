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
        }
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
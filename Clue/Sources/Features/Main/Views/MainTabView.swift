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
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            HomeView()
                .navigationDestination(for: AppNavigationPath.self) { destination in
                    navigationRouter.buildView(for: destination)
                }
        }
        .environmentObject(navigationRouter)
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
import SwiftUI

@main
struct ClueApp: App {
    @StateObject private var appRouter = AppRouter()
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            appRouter.buildView(for: appRouter.currentRoute)
                .environmentObject(appRouter)
                .environmentObject(authService)
                .onOpenURL { url in
                    // OAuth 콜백 처리
                    print("📱 App received URL: \(url)")
                    Task {
                        await authService.handleOAuthCallback(url: url)
                    }
                }
                .onChange(of: authService.isAuthenticated) { _, isAuthenticated in
                    // 스플래시 화면이 아닐 때만 상태 변경 처리
                    if appRouter.currentRoute != .splash {
                        appRouter.handleAuthenticationState(isAuthenticated: isAuthenticated)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .sessionCheckCompleted)) { _ in
                    // SplashView에서 세션 체크 완료 알림을 받으면 AppRouter를 통해 화면 전환
                    appRouter.handleSessionCheckCompleted(isAuthenticated: authService.isAuthenticated)
                }
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let sessionCheckCompleted = Notification.Name("sessionCheckCompleted")
}


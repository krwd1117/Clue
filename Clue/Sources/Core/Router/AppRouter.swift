import Foundation
import SwiftUI

// MARK: - Route 정의
enum Route: Hashable {
    case splash
    case login
    case main
    
    // 메인 탭 내부 라우트
    case home
}

// MARK: - AppRouter 클래스
@MainActor
class AppRouter: ObservableObject {
    @Published var currentRoute: Route = .splash
    @Published var isAnimating = false
    
    // MARK: - Navigation Methods
    
    /// 특정 라우트로 이동 (애니메이션 포함)
    func navigate(to route: Route, animated: Bool = true) {
        print("🧭 AppRouter: Navigating to \(route)")
        
        if animated {
            isAnimating = true
            
            withAnimation(.easeInOut(duration: 0.3)) {
                currentRoute = route
            }
            
            // 애니메이션 완료 후 플래그 리셋
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.isAnimating = false
            }
        } else {
            currentRoute = route
        }
    }
    
    /// 스플래시 화면으로 이동
    func showSplash() {
        navigate(to: .splash)
    }
    
    /// 로그인 화면으로 이동
    func showLogin() {
        navigate(to: .login)
    }
    
    /// 메인 화면으로 이동
    func showMain() {
        navigate(to: .main)
    }
    
    /// 홈 탭으로 이동
    func showHome() {
        navigate(to: .home, animated: false)
    }
    
    // MARK: - Authentication Flow
    
    /// 인증 상태에 따른 화면 전환
    func handleAuthenticationState(isAuthenticated: Bool) {
        print("🧭 AppRouter: Handling auth state - isAuthenticated: \(isAuthenticated)")
        
        if isAuthenticated {
            showMain()
        } else {
            showLogin()
        }
    }
    
    /// 세션 체크 완료 후 화면 전환
    func handleSessionCheckCompleted(isAuthenticated: Bool) {
        print("🧭 AppRouter: Session check completed - isAuthenticated: \(isAuthenticated)")
        
        // 약간의 딜레이 후 화면 전환 (스플래시 완료 애니메이션 고려)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.handleAuthenticationState(isAuthenticated: isAuthenticated)
        }
    }
}

// MARK: - AppRouter Extension for View Building
extension AppRouter {
    @ViewBuilder
    func buildView(for route: Route) -> some View {
        switch route {
        case .splash:
            SplashView()
        case .login:
            LoginView()
        case .main:
            MainTabView()
        case .home:
            HomeView()
        }
    }
} 

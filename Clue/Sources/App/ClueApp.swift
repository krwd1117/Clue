import SwiftUI

@main
struct ClueApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appState.currentFlow {
                case .splash:
                    SplashView(appState: appState)
                case .login:
                    LoginView(appState: appState)
                case .main:
                    MainTabView()
                        .environmentObject(appState)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: appState.currentFlow)
            .onAppear {
                Task {
                    await appState.checkSession()
                }
            }
        }
    }
}

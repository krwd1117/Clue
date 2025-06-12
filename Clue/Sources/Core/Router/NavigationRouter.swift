import Foundation
import SwiftUI

// MARK: - 네비게이션 경로 정의
enum AppNavigationPath: Hashable {
    case characterGeneration
    case characterResult(character: GeneratedCharacter)
    
    var title: String {
        switch self {
        case .characterGeneration:
            return "캐릭터 생성"
        case .characterResult:
            return "생성 결과"
        }
    }
}

// MARK: - 네비게이션 Router
@MainActor
class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()
    @Published var presentedSheet: AppNavigationPath?
    @Published var presentedFullScreenCover: AppNavigationPath?
    
    // MARK: - Stack Navigation
    
    func push(_ destination: AppNavigationPath) {
        print("🧭 NavigationRouter: Pushing \(destination)")
        path.append(destination)
    }
    
    func pop() {
        print("🧭 NavigationRouter: Popping")
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        print("🧭 NavigationRouter: Popping to root")
        path = NavigationPath()
    }
    
    // MARK: - Sheet Presentation
    
    func presentSheet(_ destination: AppNavigationPath) {
        print("🧭 NavigationRouter: Presenting sheet \(destination)")
        presentedSheet = destination
    }
    
    func dismissSheet() {
        print("🧭 NavigationRouter: Dismissing sheet")
        presentedSheet = nil
    }
    
    // MARK: - Full Screen Cover
    
    func presentFullScreenCover(_ destination: AppNavigationPath) {
        print("🧭 NavigationRouter: Presenting full screen cover \(destination)")
        presentedFullScreenCover = destination
    }
    
    func dismissFullScreenCover() {
        print("🧭 NavigationRouter: Dismissing full screen cover")
        presentedFullScreenCover = nil
    }
    
    // MARK: - View Builder
    
    @ViewBuilder
    func buildView(for destination: AppNavigationPath) -> some View {
        switch destination {
        case .characterGeneration:
            CharacterGenerationView()
        case .characterResult(let character):
            CharacterResultView(character: character, onDismiss: {
                self.pop()
            })
        }
    }
}

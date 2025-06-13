//
//  HomeRoute.swift
//  Clue
//
//  Created by 김정완 on 6/13/25.
//

import SwiftUI

enum HomeRoute {
    case characterGenerate
    case characterCreationMode
    case scenarioGenerate
}

// HomeRoute를 Identifiable로 만들기 위한 extension
extension HomeRoute: Identifiable {
    var id: String {
        switch self {
        case .characterGenerate:
            return "characterGenerate"
        case .characterCreationMode:
            return "characterCreationMode"
        case .scenarioGenerate:
            return "scenarioGenerate"
        }
    }
}

// HomeRoute를 Hashable로 만들기 위한 extension (NavigationPath용)
extension HomeRoute: Hashable {}

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
        case .characterCreationMode:
            CharacterCreationModeView()
        case .scenarioGenerate:
            Text("시나리오 생성 화면") // TODO: ScenarioGenerateView
                .font(DesignSystem.Typography.title)
        }
    }
}

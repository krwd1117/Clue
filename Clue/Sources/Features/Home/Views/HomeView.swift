//
//  HomeView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

// MARK: - 홈 뷰
struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var navigationRouter: NavigationRouter
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // 헤더 섹션
                VStack(spacing: 16) {
                    // 앱 로고
                    Image(systemName: "person.badge.plus.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                    
                    // 사용자 환영 메시지
                    if let user = authService.currentUser {
                        Text("안녕하세요, \(user.displayName ?? "창작자")님!")
                            .font(.body)
                            .foregroundColor(.blue)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.blue.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.top, 20)
                
                // 메인 액션 버튼
                VStack(spacing: 16) {
                    Button(action: {
                        viewModel.startCharacterGeneration()
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 30))
                            
                            Text("새 캐릭터 생성하기")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.purple]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                
                // 기능 소개 카드들
                VStack(spacing: 16) {
                    Text("주요 기능")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        FeatureCard(
                            icon: "gamecontroller.fill",
                            title: "장르 선택",
                            description: "판타지, SF, 로맨스 등\n다양한 장르"
                        )
                        
                        FeatureCard(
                            icon: "heart.fill",
                            title: "테마 설정", 
                            description: "구원, 복수, 사랑 등\n깊이 있는 주제"
                        )
                        
                        FeatureCard(
                            icon: "location.fill",
                            title: "배경 환경",
                            description: "중세 왕국, 우주정거장 등\n몰입도 높은 배경"
                        )
                        
                        FeatureCard(
                            icon: "doc.on.doc.fill",
                            title: "즉시 활용",
                            description: "복사, 공유 기능으로\n바로 사용 가능"
                        )
                    }
                }
                
                // 사용법 안내
                VStack(spacing: 12) {
                    Text("사용법")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 8) {
                        UsageStep(number: 1, text: "장르·테마·배경 선택")
                        UsageStep(number: 2, text: "캐릭터 생성 버튼 클릭")
                        UsageStep(number: 3, text: "결과 확인 및 활용")
                    }
                }
                
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
        .navigationTitle("홈")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            viewModel.setRouters(appRouter: appRouter, navigationRouter: navigationRouter)
            viewModel.setup()
        }
    }
}

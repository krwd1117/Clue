//
//  SplashView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI

struct SplashView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = SplashViewModel()
    @State private var logoBreathing = false
    @State private var progressRotation = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 깔끔한 흰색 배경
                Color.white
                    .ignoresSafeArea()
                
                VStack(spacing: 60) {
                    Spacer()
                    
                    // 메인 로고 섹션
                    VStack(spacing: 40) {
                        // 로고
                        ZStack {
                            // 배경 원형 효과
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 160, height: 160)
                                .scaleEffect(logoBreathing ? 1.05 : 1.0)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: logoBreathing)
                            
                            // 메인 로고
                            Image(systemName: "person.crop.artframe")
                                .font(.system(size: 80, weight: .ultraLight))
                                .foregroundColor(.blue)
                                .scaleEffect(viewModel.scale)
                                .opacity(viewModel.opacity)
                                .shadow(color: .black.opacity(0.05), radius: 10)
                        }
                        
                        // 앱 제목 및 부제목
                        VStack(spacing: 16) {
                            Text("Clue")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundColor(.black)
                                .opacity(viewModel.opacity)
                                .shadow(color: .black.opacity(0.05), radius: 5)
                            
                            Text("상상력을 현실로")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.blue)
                                .opacity(viewModel.opacity)
                            
                            Text("✨ 캐릭터 창작의 마법이 시작됩니다 ✨")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.gray)
                                .opacity(viewModel.opacity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // 로딩 섹션
                    VStack(spacing: 20) {
                        Text("앱을 준비하는 중...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.gray)
                            .opacity(viewModel.opacity)
                        
                        // 프로그래스 뷰
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(progressRotation ? 360 : 0))
                                .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: progressRotation)
                        }
                        .opacity(viewModel.opacity)
                    }
                    
                    Spacer()
                    
                    // 하단 장식
                    VStack(spacing: 8) {
                        Text("🎨 • 🎭 • ✏️ • 🌟")
                            .font(.system(size: 20))
                            .opacity(viewModel.opacity * 0.6)
                        
                        Text("창작자들의 무한한 가능성")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.gray)
                            .opacity(viewModel.opacity)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            viewModel.startAnimation()
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
                logoBreathing = true
            }
            
            withAnimation(.linear(duration: 1).repeatForever(autoreverses: false).delay(1.5)) {
                progressRotation = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .sessionCheckCompleted)) { _ in
            // 세션 체크 완료 후 화면 전환
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if viewModel.isAuthenticated {
                    appRouter.navigate(to: .main)
                } else {
                    appRouter.navigate(to: .login)
                }
            }
        }
    }
}

#Preview {
    SplashView()
        .environmentObject(AppRouter())
        .environmentObject(AuthService.shared)
} 


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
    @State private var particlesVisible = false
    @State private var logoBreathing = false
    @State private var textPulse = false
    @State private var progressPulse = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 창작 테마 배경 그라디언트
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.25), // 미드나잇 블루
                        Color(red: 0.15, green: 0.08, blue: 0.35), // 깊은 보라
                        Color(red: 0.25, green: 0.15, blue: 0.45), // 중간 보라
                        Color(red: 0.35, green: 0.25, blue: 0.55)  // 밝은 보라
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // 떠다니는 창작 파티클들
                ForEach(0..<12, id: \.self) { index in
                    SplashParticle(index: index)
                        .opacity(particlesVisible ? 0.3 : 0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .delay(Double(index) * 0.1),
                            value: particlesVisible
                        )
                }
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // 메인 로고 섹션
                    VStack(spacing: 30) {
                        // 로고 배경 효과
                        ZStack {
                            // 외부 오라
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.cyan.opacity(0.3),
                                            Color.purple.opacity(0.2),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 200, height: 200)
                                .scaleEffect(logoBreathing ? 1.2 : 1.0)
                                .opacity(0.6)
                            
                            // 중간 오라
                            Circle()
                                .fill(
                                    RadialGradient(
                                        gradient: Gradient(colors: [
                                            Color.pink.opacity(0.2),
                                            Color.orange.opacity(0.1),
                                            Color.clear
                                        ]),
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 80
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .scaleEffect(logoBreathing ? 0.9 : 1.1)
                                .opacity(0.8)
                            
                            // 메인 로고
                            Image(systemName: "person.crop.artframe")
                                .font(.system(size: 80, weight: .ultraLight))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color.cyan.opacity(0.9),
                                            Color.purple.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .scaleEffect(viewModel.scale)
                                .opacity(viewModel.opacity)
                                .rotationEffect(.degrees(viewModel.rotationAngle))
                                .shadow(color: .cyan.opacity(0.5), radius: 20)
                        }
                        
                        // 앱 제목 및 부제목
                        VStack(spacing: 16) {
                            Text("Clue")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color.white,
                                            Color.cyan.opacity(0.9),
                                            Color.purple.opacity(0.8)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .opacity(viewModel.opacity)
                                .scaleEffect(textPulse ? 1.05 : 1.0)
                                .shadow(color: .white.opacity(0.3), radius: 10)
                            
                            Text("상상력을 현실로")
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(.cyan.opacity(0.8))
                                .opacity(viewModel.opacity)
                            
                            Text("✨ 캐릭터 창작의 마법이 시작됩니다 ✨")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(.white.opacity(0.7))
                                .opacity(viewModel.opacity)
                                .multilineTextAlignment(.center)
                        }
                    }
                    
                    Spacer()
                    
                    // 로딩 섹션
                    VStack(spacing: 20) {
                        Text("창작 세계로 이동 중...")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                            .opacity(viewModel.opacity)
                        
                        // 커스텀 프로그래스 뷰
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(
                                    AngularGradient(
                                        colors: [.cyan, .purple, .pink, .orange, .cyan],
                                        center: .center
                                    ),
                                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                                )
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(viewModel.rotationAngle))
                                .scaleEffect(progressPulse ? 1.1 : 1.0)
                        }
                        .opacity(viewModel.opacity)
                    }
                    
                    Spacer()
                    
                    // 하단 장식
                    VStack(spacing: 8) {
                        Text("🎨 • 🎭 • ✏️ • 🌟 • 🎪")
                            .font(.system(size: 20))
                            .opacity(viewModel.opacity * 0.6)
                        
                        Text("창작자들의 무한한 가능성")
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundColor(.white.opacity(0.5))
                            .opacity(viewModel.opacity)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            viewModel.startAnimation()
            
            // 추가 애니메이션들
            withAnimation(.easeInOut(duration: 1.0).delay(0.3)) {
                particlesVisible = true
            }
            
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.0)) {
                logoBreathing = true
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.5)) {
                textPulse = true
            }
            
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(2.0)) {
                progressPulse = true
            }
        }
    }
}

// MARK: - 스플래시 파티클
struct SplashParticle: View {
    let index: Int
    @State private var isFloating = false
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.3
    
    private let symbols = [
        "sparkles", "star.fill", "heart.fill", "wand.and.stars", 
        "paintbrush.pointed", "pencil.and.outline", "lightbulb.fill", 
        "crown.fill", "leaf.fill", "flame.fill", "drop.fill", "snowflake"
    ]
    
    private let colors: [Color] = [
        .cyan, .purple, .pink, .orange, .yellow, .mint, 
        .indigo, .teal, .blue, .green, .red, .white
    ]
    
    var body: some View {
        Image(systemName: symbols[index % symbols.count])
            .font(.system(size: CGFloat.random(in: 15...30), weight: .light))
            .foregroundColor(colors[index % colors.count])
            .opacity(opacity)
            .offset(
                x: isFloating ? CGFloat.random(in: -150...150) : CGFloat.random(in: -75...75),
                y: isFloating ? CGFloat.random(in: -300...300) : CGFloat.random(in: -150...150)
            )
            .rotationEffect(.degrees(rotation))
            .animation(
                .easeInOut(duration: Double.random(in: 6...12))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.2),
                value: isFloating
            )
            .animation(
                .linear(duration: Double.random(in: 20...30))
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.1),
                value: rotation
            )
            .onAppear {
                isFloating = true
                rotation = 360
                
                // 반짝이는 효과
                Timer.scheduledTimer(withTimeInterval: Double.random(in: 2...4), repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        opacity = Double.random(in: 0.1...0.5)
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


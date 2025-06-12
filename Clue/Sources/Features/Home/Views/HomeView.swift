//
//  HomeView.swift
//  Clue
//
//  Created by 김정완 on 6/12/25.
//

import SwiftUI
import Supabase

// MARK: - 홈 뷰
struct HomeView: View {
    @EnvironmentObject var appRouter: AppRouter
    @EnvironmentObject var navigationRouter: NavigationRouter
    @EnvironmentObject var authService: AuthService
    @StateObject private var viewModel = HomeViewModel()
    @State private var isAnimating = false
    @State private var sparkleAnimation = false
    @State private var featuresVisible = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 창작 테마 배경
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.05, green: 0.05, blue: 0.2), // 깊은 네이비
                        Color(red: 0.1, green: 0.1, blue: 0.3),   // 미드나잇 블루
                        Color(red: 0.2, green: 0.1, blue: 0.4),   // 깊은 보라
                        Color(red: 0.3, green: 0.2, blue: 0.5)    // 중간 보라
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea(.all)
                
                // 떠다니는 창작 요소들
                ForEach(0..<8, id: \.self) { index in
                    FloatingCreativeElement(index: index)
                        .opacity(0.2)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 40) {
                        // 헤더 섹션 - 창작자 환영
                        CreativeHeaderSection(user: authService.currentUser, isAnimating: $isAnimating)
                            .padding(.top, 20)
                        
                        // 메인 액션 버튼 - 캐릭터 생성
                        CharacterGenerationButton(
                            sparkleAnimation: $sparkleAnimation,
                            action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    viewModel.startCharacterGeneration()
                                }
                            }
                        )
                        
                        // 기능 소개 카드들
                        CreativeFeaturesSection(featuresVisible: $featuresVisible)
                        
                        // 창작 가이드 섹션
                        CreativeGuideSection()
                        
                        // 영감 섹션
                        InspirationSection()
                        
                        Spacer(minLength: 60)
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setRouters(appRouter: appRouter, navigationRouter: navigationRouter)
            viewModel.setup()
            
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
            
            withAnimation(.easeInOut(duration: 0.8).delay(0.3)) {
                featuresVisible = true
            }
            
            // 반복 애니메이션
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                sparkleAnimation = true
            }
        }
    }
}

// MARK: - 떠다니는 창작 요소
struct FloatingCreativeElement: View {
    let index: Int
    @State private var isMoving = false
    @State private var rotation: Double = 0
    
    private let symbols = ["paintbrush", "pencil.and.outline", "wand.and.stars", "person.fill", "heart.fill", "star.fill", "sparkle", "lightbulb.fill"]
    private let colors: [Color] = [.cyan, .purple, .pink, .orange, .yellow, .mint, .indigo, .teal]
    
    var body: some View {
        Image(systemName: symbols[index % symbols.count])
            .font(.system(size: CGFloat.random(in: 15...35), weight: .light))
            .foregroundColor(colors[index % colors.count])
            .opacity(0.6)
            .offset(
                x: isMoving ? CGFloat.random(in: -120...120) : CGFloat.random(in: -60...60),
                y: isMoving ? CGFloat.random(in: -250...250) : CGFloat.random(in: -125...125)
            )
            .rotationEffect(.degrees(rotation))
            .animation(
                .easeInOut(duration: Double.random(in: 4...8))
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.3),
                value: isMoving
            )
            .animation(
                .linear(duration: Double.random(in: 10...20))
                .repeatForever(autoreverses: false)
                .delay(Double(index) * 0.2),
                value: rotation
            )
            .onAppear {
                isMoving = true
                rotation = 360
            }
    }
}

// MARK: - 창작자 헤더 섹션
struct CreativeHeaderSection: View {
    let user: User?
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 메인 아이콘
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.3),
                                Color.purple.opacity(0.1),
                                Color.clear
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: 80
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: "person.crop.artframe")
                    .font(.system(size: 50, weight: .ultraLight))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .cyan.opacity(0.9), .purple.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .cyan.opacity(0.3), radius: 10)
            }
            
            // 환영 메시지
            VStack(spacing: 12) {
                if let user = user {
                    Text("환영합니다, \(user.displayName ?? "창작자")님")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .cyan.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                } else {
                    Text("창작의 세계에 오신 것을 환영합니다")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Text("✨ 오늘은 어떤 캐릭터를 만나보실까요? ✨")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.cyan.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - 캐릭터 생성 버튼
struct CharacterGenerationButton: View {
    @Binding var sparkleAnimation: Bool
    let action: () -> Void
    @State private var isPressed = false
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = false
                }
            }
            action()
        }) {
            ZStack {
                // 배경 그라디언트
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.cyan.opacity(0.8),
                                Color.purple.opacity(0.9),
                                Color.pink.opacity(0.7)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .scaleEffect(pulseScale)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseScale)
                
                // 반짝이는 오버레이
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(sparkleAnimation ? 0.3 : 0.1), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                
                // 버튼 내용
                VStack(spacing: 12) {
                    ZStack {
                        // 아이콘 배경
                        Circle()
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                    }
                    
                    Text("새 캐릭터 창조하기")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text("상상력이 현실이 되는 순간")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .shadow(
                color: Color.cyan.opacity(0.4),
                radius: isPressed ? 8 : 15,
                x: 0,
                y: isPressed ? 4 : 8
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .onAppear {
            pulseScale = 1.05
        }
    }
}

// MARK: - 창작 기능 섹션
struct CreativeFeaturesSection: View {
    @Binding var featuresVisible: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.system(size: 18))
                    .foregroundColor(.cyan)
                
                Text("창작 도구")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 16) {
                CreativeFeatureCard(
                    icon: "gamecontroller.fill",
                    title: "장르 선택",
                    description: "판타지, SF, 로맨스\n미스터리 등 다양한 세계",
                    colors: [.purple, .pink],
                    delay: 0.0
                )
                
                CreativeFeatureCard(
                    icon: "heart.circle.fill",
                    title: "테마 설정",
                    description: "구원, 복수, 사랑\n성장의 깊이 있는 주제",
                    colors: [.pink, .orange],
                    delay: 0.1
                )
                
                CreativeFeatureCard(
                    icon: "location.circle.fill",
                    title: "배경 환경",
                    description: "중세 왕국, 우주정거장\n신비로운 마법 세계",
                    colors: [.cyan, .teal],
                    delay: 0.2
                )
                
                CreativeFeatureCard(
                    icon: "square.and.arrow.up.fill",
                    title: "즉시 활용",
                    description: "복사, 공유로\n창작물에 바로 적용",
                    colors: [.mint, .green],
                    delay: 0.3
                )
            }
        }
        .opacity(featuresVisible ? 1 : 0)
        .offset(y: featuresVisible ? 0 : 30)
    }
}

// MARK: - 창작 기능 카드
struct CreativeFeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let colors: [Color]
    let delay: Double
    @State private var isVisible = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: colors.map { $0.opacity(0.3) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: colors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: colors.map { $0.opacity(0.3) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .scaleEffect(isVisible ? 1 : 0.8)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

// MARK: - 창작 가이드 섹션
struct CreativeGuideSection: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "map.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.purple)
                
                Text("창작 가이드")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                CreativeGuideStep(
                    number: 1,
                    icon: "1.circle.fill",
                    text: "장르·테마·배경 선택으로 세계관 구축",
                    color: .cyan
                )
                
                CreativeGuideStep(
                    number: 2,
                    icon: "2.circle.fill",
                    text: "AI가 당신의 상상력을 현실로 변환",
                    color: .purple
                )
                
                CreativeGuideStep(
                    number: 3,
                    icon: "3.circle.fill",
                    text: "완성된 캐릭터를 저장하고 활용",
                    color: .pink
                )
            }
        }
    }
}

// MARK: - 창작 가이드 스텝
struct CreativeGuideStep: View {
    let number: Int
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 40)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - 영감 섹션
struct InspirationSection: View {
    private let inspirations = [
        "🌟 \"모든 캐릭터에는 이야기가 있다\"",
        "✨ \"상상력이 현실을 만든다\"",
        "🎭 \"당신의 창작물이 세상을 바꾼다\"",
        "🎨 \"예술은 영혼의 언어다\""
    ]
    
    @State private var currentIndex = 0
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.yellow)
                
                Text("오늘의 영감")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ZStack {
                ForEach(0..<inspirations.count, id: \.self) { index in
                    Text(inspirations[index])
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .opacity(currentIndex == index ? 1 : 0)
                        .scaleEffect(currentIndex == index ? 1 : 0.8)
                        .animation(.easeInOut(duration: 0.5), value: currentIndex)
                }
            }
            .frame(height: 50)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.yellow.opacity(0.1),
                                Color.orange.opacity(0.05)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
                withAnimation {
                    currentIndex = (currentIndex + 1) % inspirations.count
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
        .environmentObject(AppRouter())
        .environmentObject(NavigationRouter())
        .environmentObject(AuthService.shared)
}
